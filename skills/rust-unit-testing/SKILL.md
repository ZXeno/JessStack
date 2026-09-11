---
name: rust-unit-testing
description: Guidance for writing effective, thorough, well-organized unit tests in Rust. Covers splitting large test suites across files/modules, scenario coverage (valid, invalid, missing, boundary, and unexpected inputs), writing regression tests for fixed bugs, designing tests that prevent bugs rather than just confirm current behavior, behavior-focused testing over implementation-coupled assertions, table-driven and property-based testing, and common Rust testing pitfalls (flaky tests, over-mocking, brittle assertions). Use this skill whenever writing new unit tests in Rust, reviewing or expanding an existing Rust test suite, refactoring a large `#[cfg(test)] mod tests` block, fixing a bug and needing a regression test, or when the user asks for "good tests", "thorough tests", "test coverage" for Rust code, or mentions flaky or brittle Rust tests.
---

# Rust Unit Testing

## Philosophy

A test suite has two jobs: document what the code is supposed to do, and catch it when that stops being true. Tests that only restate the current implementation in a different form satisfy neither job — they pass as long as the code doesn't change, and say nothing about whether the code is *correct*. Write tests against the contract (what a function promises its callers), not against the implementation (how it currently happens to work). A test that would need rewriting after a pure refactor — same inputs, same outputs, different internals — is usually testing the wrong thing.

Treat test-writing as a design activity, not paperwork done after the fact. Before or while writing a function, ask "what has to stay true no matter how this is implemented?" and "what's the nastiest input someone could hand this?" Tests that come from those questions catch bugs you haven't thought of yet, not just the one that prompted this session.

## Workflow

When asked to write or expand tests for a Rust file:

1. **Read the code under test fully first.** Identify the public contract of each function/type: parameters and their valid ranges, return type and every variant it can take (including `Err` and `None`), documented invariants, and anything implied but undocumented (e.g., "this always returns a sorted `Vec`").
2. **Inventory scenarios** using the checklist below before writing anything. Do this as a short list of bullet points — it's cheap and catches gaps that are easy to miss once you're heads-down writing assertions.
3. **Decide file organization** based on current and resulting test count — see `references/organization-and-structure.md`.
4. **Write tests grouped by concern**: happy path, invalid/missing input, boundary values, error paths, and regressions as separate groups (separate files once a module gets large; see the reference doc).
5. **Add a regression test for any bug fixed as part of this work** — see the Regression Tests section below.
6. **Before finishing, self-check against common pitfalls** — see `references/pitfalls-and-antipatterns.md` and the checklist at the end of this file.

## Core principle: test behavior, not implementation

Assert on what a caller can observe — return values, `Err` variants, mutations to arguments passed by reference, side effects like files written or messages sent — not on internal fields, private helper calls, or incidental representation details.

```rust
// Brittle: coupled to the exact internal layout. Breaks on any refactor
// of Cache's fields, even when behavior is unchanged.
assert_eq!(
    format!("{cache:?}"),
    "Cache { entries: [(\"a\", 1)], capacity: 10 }"
);

// Behavior-focused: asserts the contract (what get() returns), survives
// internal refactors.
assert_eq!(cache.get("a"), Some(&1));
```

A useful test of whether a test is behavior-focused: if you rewrote the function's internals (different algorithm, different data structure) but kept its documented contract, would this test still make sense and still pass? If not, it's testing implementation.

This doesn't mean internals are never worth testing — a private helper with real logic and its own edge cases deserves tests too. Just keep those tests scoped to that helper's own contract rather than reaching into a public type's guts to check on it indirectly.

## Scenario coverage checklist

For every function or method under test, deliberately consider each of these — not every one applies every time, but decide that deliberately rather than by omission:

- **Valid/typical input** — more than one representative case; don't stop at the first example that comes to mind.
- **Invalid input** — wrong shape, malformed data, an invalid enum discriminant if constructed unsafely, invalid UTF-8 for anything crossing a byte boundary, values that violate a documented precondition.
- **Missing/absent input** — `None`, empty string, empty collection, zero-length slice, default-constructed values, optional fields left unset.
- **Boundary values** — `0`, `1`, `-1`, `MIN`/`MAX` for the numeric type in play, one-past-the-end indices, empty vs. single-element vs. many-element collections, off-by-one boundaries in ranges and loops.
- **Unexpected/adversarial input** — very large input, duplicate entries, out-of-order data, deeply nested structures, Unicode edge cases (multi-byte characters, combining characters, empty string vs. whitespace-only string, RTL text if strings are user-facing).
- **Every error path** — every `Result::Err` variant and every `Option::None` branch should be reachable and asserted on, not just the `Ok`/`Some` cases.
- **State transitions** — for stateful types, test invalid or out-of-order transitions (e.g., calling `finish()` twice, or before `start()`), not just the one linear happy path.
- **Resource cleanup** — where relevant, verify `Drop` runs, files/handles are closed, and locks are released, especially on early-return/error paths.

## Writing the tests

- **Name for subject, condition, and expected outcome**: `fn parse_config_missing_required_field_returns_error()`, not `fn test_parse()` or `fn it_works()`. A failing test name should tell you most of what broke without reading the body.
- **One behavior per test.** A test asserting several unrelated things makes failures hard to diagnose and breaks for the wrong reasons when unrelated code changes. Splitting is essentially free in Rust — each `#[test]` fn is independent and reports its own pass/fail.
- **Prefer `Result`-returning tests over blind `unwrap()`.** Use `-> Result<(), E>` with `?` for setup steps so a setup failure reports clearly via `?`, and reserve explicit `assert_*!` (or a well-labeled `.expect("...")`) for the actual behavior under test:

  ```rust
  #[test]
  fn parses_valid_config() -> Result<(), Box<dyn std::error::Error>> {
      let cfg = Config::parse(SAMPLE)?;
      assert_eq!(cfg.name, "prod");
      Ok(())
  }
  ```

- **Use table-driven tests or `rstest` parametrization** to cover many scenarios without duplicating test bodies — see `references/organization-and-structure.md` for both patterns.
- **Add property-based tests (`proptest`/`quickcheck`) for pure functions with rich input domains**, alongside example-based tests. A property test states an invariant that must hold for *all* inputs (round-trip encode/decode, monotonicity, idempotence) rather than pinning one output value — this is one of the strongest tools for behavior-focused testing, since it can't accidentally encode "whatever the current implementation happens to output."
- **Match `#[should_panic]` against a specific substring**: `#[should_panic(expected = "index out of bounds")]`. An unconstrained `#[should_panic]` passes even when the panic comes from an unrelated bug.

## Regression tests

When a bug is found and fixed, capture it so it can never silently come back:

1. Write a test that reproduces the bug and confirm it fails against the pre-fix code (red), then fix the bug and confirm it passes (green). If the fix already landed before the test was written, temporarily revert it locally to confirm the new test actually catches the bug — a regression test that never failed against the broken code isn't proven to catch anything.
2. Name the test to reference the defect, e.g. `fn regression_empty_batch_panics_on_flush()`, and add a one-line comment with the issue/PR link or a short description of the original symptom, so future readers know why the test exists and can find more context.
3. Generalize slightly beyond the exact failing input where it's cheap to do so. If a specific 3-item batch crashed because of an off-by-one, also cover 0-, 1-, and 2-item batches — otherwise the fix's coverage can degrade to one magic case that doesn't protect against the same class of bug resurfacing at a different size.
4. Keep regression tests easy to find — a dedicated `mod regression` (or `regression.rs` file once there are several) so they don't get quietly deleted or merged away during later refactors.

## Designing tests to prevent bugs, not just catch known ones

- Before or right after implementing, ask "what could break this?" and write one test per invariant you come up with, not just per line of code.
- Favor tests that would fail for a whole *class* of incorrect implementations over tests that only happen to catch the one bug you just fixed — property-based tests are particularly good at this.
- Pay extra attention to the classic off-by-one and overflow territory: loop bounds, slice indexing, numeric casts (`as` conversions truncate/wrap silently), and arithmetic that can overflow or underflow — add explicit `MIN`/`MAX` cases and prefer exercising `checked_`/`wrapping_`/`saturating_` variants where the function uses them.
- For generic functions or trait objects, test with more than one meaningfully different concrete type. A generic tested against only one implementor can pass while secretly depending on that implementor's quirks.

## File organization for large test suites

Keep small test modules inline with `#[cfg(test)] mod tests { ... }` in the same file as the code. Once that module gets unwieldy — a rough signal is needing to scroll past several unrelated concerns to find a test, or tests for clearly distinct concerns (happy path vs. error handling vs. regressions) piling into one block — split by concern into separate files.

Full patterns, directory layouts, and worked examples (including the `#[path]`/directory approaches and when to use true integration tests under `tests/`) are in `references/organization-and-structure.md`. Read it before restructuring an existing test module.

## Before finishing

- Every public function/method with a fallible or optional return has at least one test on its failure path, not just its success path.
- Boundary, empty/zero, and missing-input cases are covered, not only the "normal" case.
- Tests assert observable behavior, not internal representation — check by asking whether a pure refactor would break them.
- No test depends on execution order or leaks mutable state (env vars, statics, fixed file paths) into other tests.
- If this work included a bug fix, a regression test exists for it and was confirmed to fail against the pre-fix code.
- Skim `references/pitfalls-and-antipatterns.md` for anything that applies to what was just written.
- Test file/module organization matches current suite size per `references/organization-and-structure.md`.
