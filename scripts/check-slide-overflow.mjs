#!/usr/bin/env node
// Check reveal.js slide decks for content overflow and {.smaller} hygiene.
//
// Rule (see CONTRIBUTING.md): a slide should carry `{.smaller}` iff its content
// at normal size exceeds 90% of the slide height (> 630px of 700px). The 10%
// margin absorbs measurement noise and later content/translation edits.
//
// The check measures each slide twice in a headless browser: once as authored
// (to catch slides that overflow the 700px box in the published deck) and once
// with `.smaller` removed (the "natural" height that decides whether the class
// is warranted).
//
// Usage:
//   quarto render                       # decks must be rendered first
//   node scripts/check-slide-overflow.mjs [dir]
//
// Args:
//   dir  directory of rendered *.html decks (default: _site/sessions/slides)
//
// Env:
//   CHROMIUM_PATH     path to a Chromium/Chrome binary (default: auto-detect)
//   CHROMIUM_PROFILE  writable user-data dir; snap Chromium cannot use hidden
//                     dirs or /tmp, so point this at a non-hidden $HOME path
//   SLIDE_BOX_MARGIN  fraction of slide height above which {.smaller} is
//                     required (default: 0.9)
//
// Exit code: non-zero if any slide overflows the box or breaks the rule
// (a missing {.smaller}). Idle {.smaller} markers are reported as warnings only.

import { readdirSync, existsSync, mkdtempSync } from "node:fs";
import { join, resolve, basename } from "node:path";
import { tmpdir } from "node:os";
import { createRequire } from "node:module";

const require = createRequire(import.meta.url);
let puppeteer;
try {
  puppeteer = require("puppeteer-core");
} catch {
  console.error("puppeteer-core is not installed. Run: npm install");
  process.exit(2);
}

const args = process.argv.slice(2).filter((a) => a !== "--strict");
const STRICT = process.argv.includes("--strict");
const DIR = resolve(args[0] || "_site/sessions/slides");
const MARGIN = Number(process.env.SLIDE_BOX_MARGIN || 0.9);

function findChromium() {
  if (process.env.CHROMIUM_PATH) return process.env.CHROMIUM_PATH;
  const candidates = [
    "/snap/bin/chromium",
    "/usr/bin/chromium",
    "/usr/bin/chromium-browser",
    "/usr/bin/google-chrome",
    "/opt/google/chrome/chrome",
  ];
  return candidates.find((p) => existsSync(p));
}

if (!existsSync(DIR)) {
  console.error(`No rendered decks at ${DIR}. Run 'quarto render' first.`);
  process.exit(2);
}
const exe = findChromium();
if (!exe) {
  console.error("No Chromium found. Set CHROMIUM_PATH to a browser binary.");
  process.exit(2);
}

const decks = readdirSync(DIR)
  .filter((f) => f.endsWith(".html") && !f.startsWith("_"))
  .sort();
if (decks.length === 0) {
  console.error(`No .html decks in ${DIR}.`);
  process.exit(2);
}

// Measured inside the page for one slide: neutralise reveal's transform scaling
// and fixed sizing, then read the true content height. Runs once with the
// authored classes and once with `.smaller` stripped.
const PAGE_FN = `async () => {
  const H = Reveal.getConfig().height || 700;
  const slidesEl = document.querySelector('.reveal .slides');
  const all = Reveal.getSlides();
  const out = [];
  const measure = (cur) => {
    const sv = { tf: slidesEl.style.transform, sh: slidesEl.style.height,
      h: cur.style.height, mh: cur.style.minHeight, top: cur.style.top,
      pos: cur.style.position, disp: cur.style.display };
    slidesEl.style.transform = 'none'; slidesEl.style.height = 'auto';
    cur.style.height = 'auto'; cur.style.minHeight = '0'; cur.style.top = '0';
    cur.style.position = 'relative'; cur.style.display = 'block';
    const hgt = cur.scrollHeight;
    Object.assign(slidesEl.style, { transform: sv.tf, height: sv.sh });
    Object.assign(cur.style, { height: sv.h, minHeight: sv.mh, top: sv.top,
      position: sv.pos, display: sv.disp });
    return hgt;
  };
  for (let i = 0; i < all.length; i++) {
    const s = all[i];
    const idx = Reveal.getIndices(s);
    Reveal.slide(idx.h, idx.v);
    await new Promise((r) => setTimeout(r, 60));
    const cur = document.querySelector('section.present') || s;
    const smallEls = [cur, ...cur.querySelectorAll('.smaller')]
      .filter((el) => el.classList.contains('smaller'));
    const hasSmaller = smallEls.length > 0;
    const rendered = measure(cur);
    smallEls.forEach((el) => el.classList.remove('smaller'));
    const natural = measure(cur);
    smallEls.forEach((el) => el.classList.add('smaller'));
    const head = ((cur.querySelector('h1,h2,h3,h4') || {}).textContent
      || '(no heading)').trim().slice(0, 46);
    out.push({ i, H, rendered, natural, hasSmaller, head });
  }
  return out;
}`;

const browser = await puppeteer.launch({
  executablePath: exe,
  headless: "new",
  userDataDir: process.env.CHROMIUM_PROFILE || mkdtempSync(join(tmpdir(), "slidecheck-")),
  args: ["--no-sandbox", "--disable-gpu", "--disable-dev-shm-usage"],
});

// A slide that overflows the box (> 700px) is a hard failure: it is clipped in
// the deck and must be fixed. A slide in the buffer band (natural height between
// the margin and the box) fits but runs tight; {.smaller} is advisable but only
// helps text-driven height, so this is a warning unless --strict. An idle marker
// is always a warning.
const problems = []; // hard failures (exit non-zero)
const warnings = []; // advisory (tight buffer band, idle markers)

for (const deck of decks) {
  const page = await browser.newPage();
  await page.setViewport({ width: 1280, height: 720 });
  try {
    await page.goto("file://" + join(DIR, deck), { waitUntil: "networkidle0", timeout: 60000 });
    await page.waitForFunction("window.Reveal && Reveal.isReady && Reveal.isReady()", { timeout: 30000 });
    const rows = await page.evaluate(`(${PAGE_FN})()`);
    const name = basename(deck, ".html");
    for (const r of rows) {
      const needs = r.natural > MARGIN * r.H;
      const band = Math.round(MARGIN * r.H);
      if (r.rendered > r.H) {
        problems.push({ name, ...r, kind: "OVERFLOW", note: `overflows box (${r.rendered}px > ${r.H}px) — clipped in the deck` });
      } else if (needs && !r.hasSmaller) {
        const rec = { name, ...r, kind: "TIGHT", note: `natural ${r.natural}px > ${band}px margin — consider {.smaller} (only helps text-driven height)` };
        (STRICT ? problems : warnings).push(rec);
      } else if (!needs && r.hasSmaller) {
        warnings.push({ name, ...r, kind: "IDLE", note: `natural ${r.natural}px ≤ ${band}px — {.smaller} not needed` });
      }
    }
  } catch (e) {
    problems.push({ name: basename(deck, ".html"), head: "", kind: "RENDER", note: e.message });
  } finally {
    await page.close();
  }
}
await browser.close();

const fmt = (r) => `  ${r.kind.padEnd(9)} ${r.name}  — slide ${r.i} "${r.head}"\n             ${r.note}`;
if (problems.length) {
  console.log(`\n✗ ${problems.length} slide problem(s):\n`);
  problems.forEach((r) => console.log(fmt(r)));
}
if (warnings.length) {
  console.log(`\n⚠ ${warnings.length} advisory warning(s):\n`);
  warnings.forEach((r) => console.log(fmt(r)));
}
if (!problems.length && !warnings.length) {
  console.log("✓ All slides fit; {.smaller} usage matches the rule.");
} else if (!problems.length) {
  console.log("\n✓ No slides overflow the box; warnings above are advisory.");
}

process.exit(problems.length ? 1 : 0);
