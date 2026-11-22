# Rust comment rules

These rules add to the core rules in `comment-terminator.md`.

## Scope

- `.rs` files: `//` and `/* */` comments, and `///`, `//!`, `/** */`, and `/*! */` doc comments.
- `Cargo.toml` files: `#` comments and `allow` entries in the `[lints]` tables.

## Skip

Skip these files. List each one in skips.

- Everything under `target/`.
- Any file with an `@generated` header.
- Files that a build script writes to `OUT_DIR`, such as `prost` or `bindgen` output.

## Walk away

- Non-obvious behavior forced by FFI, a C ABI, a platform syscall, or a crate bug.
- `///`, `//!`, `/** */`, and `/*! */` on a `pub` item of a library crate that another crate depends on. Docs on a `pub(crate)`, `pub(super)`, or private item die. Docs that restate the item name die.
- A doc comment with a code block holds a doctest. On a non-public item, skip it and list it in skips. Do not delete a test.
- `// SAFETY:` on an `unsafe` block or `unsafe impl`, when it states the invariant that makes the code sound. A `// SAFETY:` that only says the code is safe dies with a flag on the `unsafe` block.
- Formatter directives: `#[rustfmt::skip]` and `#![rustfmt::skip]`.

## Suppressions

Delete these forms:

- `#[allow(<lint>)]`, `#![allow(<lint>)]`, `#[expect(<lint>)]`, and `#![expect(<lint>)]`.
- `#[cfg_attr(<cond>, allow(<lint>))]`.
- An `allow` entry in `[lints.rust]` or `[lints.clippy]` of `Cargo.toml`, or in `[workspace.lints]`.

Delete only the guilty lint from an attribute that lists several. Delete the attribute when no lint remains.

Style-only lints survive: the `clippy::style` group, `clippy::module_name_repetitions`, `clippy::doc_markdown`, `clippy::must_use_candidate`, and other naming or documentation lints of the `clippy::pedantic` group.

Correctness, reliability, and safety lints die with a flag. Examples: the `clippy::correctness` and `clippy::suspicious` groups, `unused_must_use`, `dead_code`, `unused`, `warnings`, `unsafe_code`, `clippy::unwrap_used`, `clippy::expect_used`, `clippy::panic`, `clippy::indexing_slicing`, `clippy::arithmetic_side_effects`, `clippy::await_holding_lock`, and `clippy::undocumented_unsafe_blocks`.

## Tracing

Use the LSP tool for references and definitions. Fall back to Grep. Run `cargo clippy --all-targets` to see which warning a deleted suppression brings back.
