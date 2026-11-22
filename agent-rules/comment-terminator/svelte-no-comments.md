# Svelte comment rules

These rules add to the core rules in `comment-terminator.md`.

## Scope

- `.svelte` files: `<!-- -->` comments in markup, `//` and `/* */` comments in `<script>`, and `/* */` comments in `<style>`.
- `.svelte.ts` and `.svelte.js` modules.

Read `ts-no-comments.md` too. It applies to every `<script>` block and to every `.svelte.ts` and `.svelte.js` module.

## Skip

Skip everything under `.svelte-kit/`, `build/`, and `node_modules/`. List each skipped file in skips.

## Walk away

- `<!-- @component -->` in a component that another package consumes. It is the component's public API doc. In any other component it dies.
- Formatter directives: `<!-- prettier-ignore -->` in markup and `/* prettier-ignore */` in `<style>`.

## Dies

- Commented-out markup, such as `<!-- <Button /> -->`.

## Suppressions

Delete these forms:

- `<!-- svelte-ignore <code> -->` in markup, and `// svelte-ignore <code>` in `<script>`.
- `/* stylelint-disable */` and its matching `/* stylelint-enable */`, and `/* stylelint-disable-next-line */`.

Accessibility warnings protect users. Every `a11y_*` code dies with a flag on the element.

Reactivity warnings catch real bugs. `state_referenced_locally`, `non_reactive_update`, `ownership_invalid_binding`, and `ownership_invalid_mutation` die with a flag.

`css_unused_selector` dies with a flag. A selector that styles markup outside the component belongs in `:global()`.

## Tracing

Use the LSP tool and Grep. Run `npx svelte-check` to see which warning a deleted suppression brings back.
