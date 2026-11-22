# TypeScript and JavaScript comment rules

These rules add to the core rules in `comment-terminator.md`.

## Scope

`.ts`, `.tsx`, `.js`, `.jsx`, `.mjs`, `.cjs`, `.mts`, and `.cts` files: `//` and `/* */` comments, and `/** */` JSDoc and TSDoc comments.

## Skip

Skip these files. List each one in skips.

- Everything under `node_modules/`, `dist/`, `build/`, `coverage/`, and `.svelte-kit/`.
- `*.min.js`, and `*.d.ts` files that a build emits.
- Any file with an `@generated` or `auto-generated` header.

## Walk away

- `/** */` on an exported symbol of a package that another package consumes, either published or imported by another workspace package. `/** */` on a module-private symbol dies. `/** */` that restates the symbol name dies.
- JSDoc type tags (`@type`, `@param {T}`, `@returns {T}`, `@typedef`) in a `.js` file that `tsc` checks. They are type annotations, not prose. Their prose text still dies.
- Formatter directives: `// prettier-ignore`, `// dprint-ignore`, and `// biome-ignore format: <reason>`.
- Tool directives: a shebang, `/// <reference ... />`, `// @ts-check`, `//# sourceMappingURL=`, `// @vitest-environment <env>`, `/** @jsxImportSource <pkg> */`, and bundler magic comments such as `/* webpackChunkName: */`, `/* @vite-ignore */`, `/*#__PURE__*/`, and `/* @__PURE__ */`.

## Suppressions

Delete these forms:

- `// eslint-disable-next-line`, `// eslint-disable-line`, and `/* eslint-disable */` with its matching `/* eslint-enable */`.
- `// biome-ignore lint/<rule>` and `// oxlint-disable`.
- `// @ts-ignore` and `// @ts-nocheck`. They hide a type error, so they always die with a flag.
- `// @ts-expect-error`. It survives only in a type test, such as a `*.test-d.ts` file, where it asserts that the next line fails to compile. Everywhere else it dies with a flag.
- Coverage exclusions: `/* istanbul ignore */`, `/* c8 ignore */`, and `/* v8 ignore */`.

Flag only, never edit:

- The non-null `!` operator.
- `as any`, `as unknown as T`, and `as never`.

Style-only rules survive: `max-len`, `prettier/prettier`, `import/order`, `sort-imports`, and `@typescript-eslint/naming-convention`.

Correctness and safety rules die with a flag. Examples: `@typescript-eslint/no-floating-promises`, `@typescript-eslint/no-misused-promises`, `@typescript-eslint/no-unsafe-*`, `@typescript-eslint/no-explicit-any`, `@typescript-eslint/no-non-null-assertion`, `react-hooks/rules-of-hooks`, `react-hooks/exhaustive-deps`, `no-undef`, and `no-restricted-syntax` entries that the project wrote.

## Tracing

Use the LSP tool for references and definitions. Fall back to Grep.
