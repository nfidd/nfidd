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

A few rules of thumb:

- Use the full `::: {.callout-TYPE}` syntax (braces and a leading dot on the class)
  and quote attribute values (`collapse="true"`).
- Don't use `collapse="true"` on its own to mean "optional". Collapse is for
  Solutions. Mark genuinely optional content with the `.optional` class so readers
  can tell the difference.
- Every session ends with one `# Going further` section (a single `#` heading) for
  self-study material: challenges, deeper reading, and extensions.

## How the course is taught

The taught material is the main thread of each session. Optional asides and the
"Going further" section are genuinely optional: participants are expected to work
through the main material first and come back to the optional content later or
after the course. Bear this in mind when deciding whether new material belongs in
the main flow or in an optional box.

See also the [learning objectives](reference/learning_objectives.qmd) for what each
session should leave participants able to do.
