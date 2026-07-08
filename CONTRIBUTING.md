# Contributing to NFIDD

Thanks for helping improve the course. This note covers the conventions for
writing session content so the material stays consistent and easy to follow.

## Callouts and optional material

We use a small set of boxed content types. Use them consistently:

- **Exercises**: `::: {.callout-tip}` with a "Take N minutes" title. The task for
  participants. Not collapsed.
- **Solutions**: `::: {.callout-note collapse="true"}` with a "Solution" title.
  Collapsed so participants try the exercise first.
- **Essential notes**: `::: {.callout-note}` or `::: {.callout-tip}`. Short
  clarifications everyone should read. Keep them brief.
- **Optional asides / going deeper**: add the `.optional` class:
  `::: {.callout-note .optional collapse="true"}`. The class styles the box as
  skippable (a "· optional" label and muted border, see `styles.css`). Use it for
  depth that isn't needed to follow the main thread, and keep it where it makes
  sense in context.
- **Self-contained extensions**: put these under the session's `# Going further`
  heading at the end of the file, rather than inline.
- **Optional sections kept in place**: if a longer optional section reads best where
  it sits rather than under "Going further", add the `.optional` class to its
  heading, e.g. `## Going deeper {.optional}`. It gets the same "· optional" label.

A few rules of thumb:

- Use the full `::: {.callout-TYPE}` syntax (braces and a leading dot on the class)
  and quote attribute values (`collapse="true"`).
- Don't use `collapse="true"` on its own to mean "optional". Collapse is for
  Solutions. Mark genuinely optional content with the `.optional` class so readers
  can tell the difference.
- Every session ends with one `# Going further` section (a single `#` heading) for
  self-study material such as challenges and further reading.

## How the course is taught

The taught material is the main thread of each session. Optional asides and the
"Going further" section are genuinely optional: participants work
through the main material first and return to optional content later or
after the course. Bear this in mind when deciding whether new material belongs in
the main flow or in an optional box.

See also the [learning objectives](reference/learning_objectives.qmd) for what each
session should leave participants able to do.

## Slides

Slide decks live in `sessions/slides/` and render with reveal.js at a fixed
960×700 logical size. Content taller than 700px is clipped in the presentation.

### `{.smaller}`

Decks set no `smaller` default. Add `{.smaller}` to a slide **iff its content at
normal size exceeds 90% of the slide height (> 630px of 700px)** — a 10% safety
margin that absorbs measurement noise and later content or translation edits.
Below that, leave it off. `{.smaller}` shrinks text only, so a slide whose height
comes from a plot or image needs its figure resized, not the class.

### Testing it

`scripts/check-slide-overflow.mjs` renders each deck and measures every slide:

```sh
npm install          # once, installs puppeteer-core
quarto render        # decks must be rendered to _site first
npm run check-slides  # fails if any slide overflows the 700px box
```

It exits non-zero on slides that overflow the box (a clipped-slide bug) and
reports advisory warnings for slides that run tight without `{.smaller}` or carry
an idle one. Add `--strict` to also fail on the tight buffer band. The check
needs a Chromium binary; set `CHROMIUM_PATH` if it is not auto-detected (and, for
snap Chromium, `CHROMIUM_PROFILE` to a non-hidden `$HOME` directory).
