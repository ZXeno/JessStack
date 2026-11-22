# Organizing and Splitting Rust Test Suites

## Decision guide

| Situation | Approach |
|---|---|
| Small module, a handful of tests | Inline `#[cfg(test)] mod tests` at the bottom of the file |
| Module's inline test block is growing hard to scan, or mixes clearly distinct concerns | Split into files by concern, still compiled only under `#[cfg(test)]` |
| Tests need to exercise the crate only through its public API, as an external consumer would | True integration tests under the crate-root `tests/` directory |
| Many near-identical cases differing only in input/output | Table-driven loop, or `rstest` case parametrization — don't split into files for this, reduce duplication instead |

The first move when a test module gets big is usually *not* more files — it's checking whether cases can collapse into a table-driven or `rstest`-parametrized test (see below). Only split into files once the tests genuinely cover distinct concerns that benefit from being found and read separately.

## Pattern 1: Inline (default for most modules)

```rust
// src/parser.rs
pub fn parse(input: &str) -> Result<Ast, ParseError> {
    // ...
}

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn parses_valid_expression() {
        assert!(parse("1 + 2").is_ok());
    }

    #[test]
    fn empty_input_returns_error() {
        assert!(matches!(parse(""), Err(ParseError::Empty)));
    }
}
```

Stay here as long as it's comfortable. Most modules never need to graduate past this.

## Pattern 2: Splitting a large inline module into files, by concern

Rust's 2018+ module resolution lets a file `foo.rs` have a submodule directory `foo/`. Use that to turn one big `mod tests` into several files without moving the implementation:

```
src/
├── parser.rs                    // implementation + `#[cfg(test)] mod tests;`
└── parser/
    └── tests/
        ├── mod.rs                // wires up the submodules below
        ├── happy_path.rs
        ├── invalid_input.rs
        ├── boundary_values.rs
        └── regression.rs
```

`src/parser.rs`:

```rust
pub fn parse(input: &str) -> Result<Ast, ParseError> {
    // ...
}

#[cfg(test)]
mod tests;
```

`src/parser/tests/mod.rs`:

```rust
mod boundary_values;
mod happy_path;
mod invalid_input;
mod regression;
```

Each leaf file reaches back to the code under test with `use super::super::*;` (leaf → `tests` → `parser`), or more readably with an absolute path:

`src/parser/tests/happy_path.rs`:

```rust
use crate::parser::*;

#[test]
fn parses_valid_expression() {
    assert!(parse("1 + 2").is_ok());
}

#[test]
fn parses_nested_expression() {
    assert!(parse("(1 + 2) * 3").is_ok());
}
```

`src/parser/tests/invalid_input.rs`:

```rust
use crate::parser::*;

#[test]
fn empty_input_returns_error() {
    assert!(matches!(parse(""), Err(ParseError::Empty)));
}

#[test]
fn unbalanced_parens_returns_error() {
    assert!(matches!(parse("(1 + 2"), Err(ParseError::UnbalancedParens)));
}
```

If a directory feels like overkill but one file is still too flat, `#[path]` lets you point directly at sibling files without the directory nesting:

```rust
// src/parser.rs
#[cfg(test)]
#[path = "parser_tests/happy_path.rs"]
mod happy_path_tests;

#[cfg(test)]
#[path = "parser_tests/invalid_input.rs"]
mod invalid_input_tests;
```

Either approach works — pick the directory form for suites that will keep growing (it scales to more files cleanly), and `#[path]` for a one-off split where a full directory feels heavier than needed.

### Shared fixtures across split files

Once tests span multiple files, duplicated setup becomes expensive to maintain — a new required field means updating every call site. Centralize construction:

```rust
// src/parser/tests/mod.rs
mod boundary_values;
mod happy_path;
mod invalid_input;
mod regression;

/// Shared test fixtures, available to all sibling test files via `super::support`.
pub(super) mod support {
    use crate::parser::*;

    pub fn sample_tokens() -> Vec<Token> {
        vec![Token::Number(1), Token::Plus, Token::Number(2)]
    }
}
```

```rust
// src/parser/tests/happy_path.rs
use crate::parser::*;
use super::support::sample_tokens;

#[test]
fn parses_token_stream() {
    assert!(Ast::from_tokens(&sample_tokens()).is_ok());
}
```

For more elaborate fixtures (multiple variants, setup/teardown), the `rstest` crate's `#[fixture]` is worth reaching for instead of hand-rolled helper functions — it composes with `#[case]` parametrization and keeps fixture wiring explicit in each test's signature.

## Pattern 3: True integration tests (`tests/` at the crate root)

Files under the top-level `tests/` directory are each compiled as their own separate crate and can only see the library's `pub` API — exactly what an external consumer sees. Use this for tests that are specifically about the public contract of the crate as a whole, not for unit-level coverage of internals (which belongs in `#[cfg(test)]` modules next to the code).

```
my-crate/
├── src/
│   └── lib.rs
└── tests/
    ├── common/
    │   └── mod.rs        // shared helpers; `common/mod.rs`, not `common.rs`,
    │                      // so it isn't itself picked up and run as a test file
    └── public_api.rs
```

```rust
// tests/public_api.rs
use my_crate::Config;

mod common;

#[test]
fn end_to_end_config_round_trip() {
    let cfg = common::sample_config();
    let encoded = cfg.to_bytes();
    let decoded = Config::from_bytes(&encoded).unwrap();
    assert_eq!(cfg, decoded);
}
```

## Reducing duplication instead of splitting: table-driven tests

Before splitting files, check whether the real problem is many near-duplicate tests that would collapse into one loop:

```rust
#[test]
fn rejects_invalid_usernames() {
    let long_name = "a".repeat(300);
    let cases = [
        ("", "empty"),
        (" ", "whitespace only"),
        (long_name.as_str(), "too long"),
        ("bad name", "contains space"),
    ];

    for (input, reason) in cases {
        assert!(
            validate_username(input).is_err(),
            "expected an error for {reason} (input: {input:?})"
        );
    }
}
```

Note the descriptive failure message — with a loop, a bare `assert!` failure won't tell you which case failed unless you say so explicitly.

## Reducing duplication with `rstest`

For cases where each input maps to a distinct expected output (not just "is this an error"), `rstest`'s case parametrization keeps each case visible and reports failures per-case rather than requiring a manual message:

```rust
use rstest::rstest;

#[rstest]
#[case("", false)]
#[case("valid_name", true)]
#[case("has space", false)]
#[case("also-valid", true)]
fn validate_username_cases(#[case] input: &str, #[case] expected_ok: bool) {
    assert_eq!(validate_username(input).is_ok(), expected_ok);
}
```

Each `#[case]` runs as its own reported test (`validate_username_cases::case_1`, etc.), so a failure points straight at the offending input without needing a custom message.

## Property-based tests for rich input domains

For pure functions where the interesting property isn't "this specific input maps to this specific output" but "this holds for every input", reach for `proptest`:

```rust
use proptest::prelude::*;

proptest! {
    #[test]
    fn round_trip_serialize_deserialize(value in any::<Config>()) {
        let encoded = value.to_bytes();
        let decoded = Config::from_bytes(&encoded).unwrap();
        prop_assert_eq!(value, decoded);
    }

    #[test]
    fn sorted_output_is_never_longer_than_input(mut xs in proptest::collection::vec(any::<i32>(), 0..500)) {
        let original_len = xs.len();
        xs.sort();
        prop_assert_eq!(xs.len(), original_len);
    }
}
```

`proptest` shrinks failing cases automatically to a minimal reproduction, which tends to make the eventual regression test (see the main `SKILL.md`) almost write itself — the shrunk case is usually exactly the input worth hard-coding as a `regression_*` test afterward.
