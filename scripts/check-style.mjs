#!/usr/bin/env node
// Check session/slide source against the conventions in CONTRIBUTING.md.
// Pure text checks (no rendering) — fast enough for a pre-commit hook or CI.
// The slide-overflow rule is checked separately by check-slide-overflow.mjs,
// which needs a browser and a rendered site.
//
// Usage: node scripts/check-style.mjs
// Exits non-zero if any convention is violated.

import { readFileSync, readdirSync } from "node:fs";
import { join } from "node:path";

const SESSIONS = "sessions";
const SLIDES = "sessions/slides";
const sessionFiles = readdirSync(SESSIONS).filter((f) => f.endsWith(".qmd")).map((f) => join(SESSIONS, f));
const slideFiles = readdirSync(SLIDES).filter((f) => f.endsWith(".qmd") && !f.startsWith("_")).map((f) => join(SLIDES, f));
const allFiles = [...sessionFiles, ...slideFiles];

const problems = [];
const report = (file, line, msg) => problems.push({ file, line, msg });

// Walk a file's lines, tracking whether we are in the YAML header, a fenced
// code block, or inside a ::: fenced div (callouts, columns). `cb` gets each
// prose line plus that context.
function walk(text, cb) {
  let inYaml = false, inFence = false, divDepth = 0;
  const lines = text.split("\n");
  lines.forEach((line, i) => {
    const s = line.trim();
    if (i === 0 && s === "---") { inYaml = true; return; }
    if (inYaml) { if (s === "---") inYaml = false; return; }
    if (s.startsWith("```")) { inFence = !inFence; return; }
    if (inFence) return;
    if (/^:::+\s*\S/.test(s)) { divDepth++; return; }   // opening fenced div
    if (/^:::+\s*$/.test(s)) { divDepth = Math.max(0, divDepth - 1); return; } // closing
    cb(line, i + 1, { divDepth });
  });
}

// Strip inline code spans so backtick contents are not scanned as prose.
const stripCode = (l) => l.replace(/`[^`]*`/g, "");

// --- 1. Headings: sessions start at #, and no downward level skips (>1) in
//        the section hierarchy. Headings inside ::: divs are callout titles and
//        do not count toward the hierarchy.
for (const file of sessionFiles) {
  const text = readFileSync(file, "utf8");
  let prev = 0, first = true;
  walk(text, (line, n, { divDepth }) => {
    const m = line.match(/^(#{1,6}) /);
    if (!m || divDepth > 0) return;
    const level = m[1].length;
    if (first) {
      if (level !== 1) report(file, n, `session starts at level ${level}, should start at "#"`);
      first = false;
    } else if (prev && level > prev + 1) {
      report(file, n, `heading skips level ${prev} -> ${level}: ${line.trim()}`);
    }
    prev = level;
  });
}

// --- 2. Slides: shared front matter must not be repeated per deck.
for (const file of slideFiles) {
  readFileSync(file, "utf8").split("\n").forEach((line, i) => {
    if (/^\s*(author|engine|chalkboard|slide-level):/.test(line)) {
      report(file, i + 1, `move "${line.trim()}" to sessions/slides/_metadata.yml`);
    }
  });
}

// --- 3. Prose: no contractions, British spelling, one sentence per line.
// ['’] matches both the straight and typographic apostrophe.
const CONTRACTION = /\b[A-Za-z]+n['’]t\b|\b(?:we|you|they|i|it|that|there|here|what|who|how|let|he|she|one)['’](?:ve|ll|re|d|s|m)\b/i;
const AMERICAN = /\b(?:model(?:ing|ed)|summariz\w+|behavior\w*|neighbor\w*|analyz\w+|visualiz\w+|optimiz\w+|organiz\w+|recogniz\w+|labeled|favor(?:ed|able|ite|s)?|catalog(?:ed|ing|s)?)\b|(?<!-)\bcolor(?:ed|ing|s|ful)?\b/i;
const SENTENCE_END = /[.!?]["')\]]?\s+[A-Z]/;
// Mask abbreviations and enumerated-list markers (globally — a line can hold more
// than one) so an internal "." after them is not read as a sentence boundary.
const ABBR = /\b(?:e\.g|i\.e|etc|et al|vs|cf|Fig|Eq|no|approx|Dr|Prof|Mr|Mrs|Ms|St|U\.S|U\.K)\.(?=\s+[A-Z])|^\s*\d+\.\s+[A-Z]/gi;

// Check heading text (minus the marker and reveal {…} attributes) for
// contractions and American spellings — the one-sentence rule does not apply.
const checkHeadingText = (file, n, line) => {
  const text = stripCode(line.replace(/^#+\s*/, "").replace(/\s*\{[^}]*\}\s*$/, ""));
  if (CONTRACTION.test(text)) report(file, n, `contraction in heading: ${text.slice(0, 70)}`);
  if (AMERICAN.test(text)) report(file, n, `American spelling in heading: ${text.slice(0, 70)}`);
};

for (const file of allFiles) {
  const text = readFileSync(file, "utf8");
  walk(text, (line, n) => {
    const s = line.trim();
    if (!s) return;
    if (/^#/.test(s)) { checkHeadingText(file, n, line); return; }
    const prose = stripCode(line);
    if (CONTRACTION.test(prose)) report(file, n, `contraction: ${s.slice(0, 70)}`);
    if (AMERICAN.test(prose)) report(file, n, `American spelling: ${s.slice(0, 70)}`);
    // one sentence per line — paragraph prose only (skip lists, quotes, tables)
    if (!/^\s*([-*+]|\d+\.|>|\|)/.test(line) && !/^\s/.test(line)) {
      let masked = prose.replace(ABBR, "x");
      if (SENTENCE_END.test(masked)) report(file, n, `multiple sentences on one line: ${s.slice(0, 70)}`);
    }
  });
}

// --- Report ---
if (problems.length === 0) {
  console.log("✓ Style checks passed.");
  process.exit(0);
}
problems.sort((a, b) => a.file.localeCompare(b.file) || a.line - b.line);
let last = "";
for (const p of problems) {
  if (p.file !== last) { console.log(`\n${p.file}`); last = p.file; }
  console.log(`  ${p.line}: ${p.msg}`);
}
console.log(`\n✗ ${problems.length} style issue(s).`);
process.exit(1);
