# Common Rust Testing Pitfalls

Skim this before finishing a batch of tests. Each entry names the smell so it's quick to check your own work against.

## 1. Testing implementation details instead of behavior

Asserting on private fields or exact `Debug` output couples the test to *how* something is built, not *what* it promises.

```rust
// Bad: breaks on any internal refactor, even a behavior-preserving one.
assert_eq!(
    format!("{cache:?}"),
    "Cache { entries: [(\"a\", 1)], capacity: 10 }"
);

// Good: asserts the contract.
assert_eq!(cache.get("a"), Some(&1));
```

## 2. Blind `unwrap()`/`expect()` everywhere

`unwrap()` on setup steps hides *which* step failed. Use `?` with a `Result`-returning test for setup, and save explicit, labeled assertions for the behavior actually under test.

```rust
// Bad: if this panics, the message is just "called `Result::unwrap()` on an `Err`"
// with no hint which of three fallible calls caused it.
#[test]
fn parses_valid_config() {
    let raw = std::fs::read_to_string("fixtures/sample.toml").unwrap();
    let cfg = Config::parse(&raw).unwrap();
    assert_eq!(cfg.name, "prod");
}

// Good: setup failures surface via `?` with their own error, the real
// assertion is explicit.
#[test]
fn parses_valid_config() -> Result<(), Box<dyn std::error::Error>> {
    let raw = std::fs::read_to_string("fixtures/sample.toml")?;
    let cfg = Config::parse(&raw)?;
    assert_eq!(cfg.name, "prod");
    Ok(())
}
```

## 3. Exact floating-point equality

Floating-point rounding makes exact equality intermittently fail across platforms/optimization levels.

```rust
// Bad: fragile.
assert_eq!(compute_average(&values), 3.3333333);

// Good: epsilon-based comparison, or the `approx` crate.
assert!((compute_average(&values) - 10.0 / 3.0).abs() < 1e-6);
// approx::assert_relative_eq!(compute_average(&values), 10.0 / 3.0, epsilon = 1e-6);
```

## 4. Assuming `HashMap`/`HashSet` iteration order

Iteration order is unspecified and can change between runs (it's randomized per-process by default).

```rust
// Bad: order isn't guaranteed.
assert_eq!(map.keys().collect::<Vec<_>>(), vec!["a", "b", "c"]);

// Good: normalize before comparing.
let mut keys: Vec<_> = map.keys().collect();
keys.sort();
assert_eq!(keys, vec!["a", "b", "c"]);
```

## 5. Shared mutable global state across tests

`cargo test` runs tests in parallel by default. Tests that mutate the same `static`, environment variable, or fixed file path race each other and produce order-dependent flakiness that's painful to debug.

```rust
// Bad: races with any other test that also sets FOO_CONFIG.
#[test]
fn reads_config_from_env() {
    std::env::set_var("FOO_CONFIG", "/tmp/test-config.toml");
    let cfg = load_config();
    assert_eq!(cfg.mode, "test");
}
```

Fix by giving each test its own isolated state — a fresh `tempfile::tempdir()` per test, dependency-injecting configuration instead of reading process-global env vars, or, only when the coupling truly can't be removed, serializing the specific tests with `#[serial]` from the `serial_test` crate. Prefer redesigning over serializing where practical — serialization just hides the shared-state coupling rather than removing it, and slows the suite down.

## 6. Sleep-based / wall-clock-dependent tests

```rust
// Bad: flaky under load; either too short (flaky failure) or wastes time
// (too long, every run pays the cost).
thread::sleep(Duration::from_millis(100));
assert!(job.is_complete());
```

Fix by polling with a timeout instead of a fixed sleep, injecting a mockable/fake clock, or — for async code — using `tokio::time::pause()` and `advance()` to control time deterministically instead of actually waiting.

## 7. Over-mocking

Mocking so much of the collaborator graph that a test only verifies the mocks were called in the expected sequence, not that real behavior is correct — it can pass even when the actual integration is broken. Mock true external boundaries only (network calls, disk I/O, the system clock, third-party services); let the rest of the real code run so the test exercises actual logic.

## 8. Only testing the success path

Every function returning `Result` needs at least one test per meaningfully distinct `Err` variant; every `Option`-returning function needs a `None` case. Untested error branches are exactly where regressions hide, because nothing signals when they silently start doing the wrong thing.

## 9. `#[should_panic]` without a message match

```rust
// Bad: passes even if the panic is from an unrelated bug elsewhere in the
// function, not the out-of-bounds access being tested.
#[test]
#[should_panic]
fn indexing_out_of_bounds() {
    let v = vec![1, 2, 3];
    let _ = v[10];
}

// Good: pins down which panic.
#[test]
#[should_panic(expected = "index out of bounds")]
fn indexing_out_of_bounds() {
    let v = vec![1, 2, 3];
    let _ = v[10];
}
```

## 10. Giant multi-assertion tests

A test asserting five unrelated behaviors makes failures hard to diagnose (which of the five broke?) and breaks for the wrong reasons when unrelated code changes. Splitting is close to free in Rust — each `#[test]` fn is independent and reports its own pass/fail — so there's little reason not to.

## 11. Vague test names

`fn test1()`, `fn it_works()`, `fn test_parse()` tell you nothing from a failing-test list. Name for subject, condition, and expected outcome: `fn parse_config_missing_required_field_returns_error()`.

## 12. Copy-pasted setup drifting across tests

When many tests each hand-construct the same multi-field struct, a new required field means updating every call site, and small copy-paste mistakes quietly produce tests that aren't testing what they claim. Centralize construction in a builder function, a `Default`-based helper, or an `rstest` `#[fixture]`.

## 13. Silent no-ops: tests that can't actually fail

An `assert!(true)` left over from a stub, or a test that checks a return value while the real effect happens elsewhere (mutating a passed-in buffer, writing a file) without checking *that*. Sanity-check new tests by temporarily breaking the implementation and confirming the test actually fails — a test that can't fail isn't testing anything.

```rust
// Bad: doesn't actually check anything meaningful about the write.
#[test]
fn writes_output_file() {
    let result = write_report(&data, "/tmp/report.txt");
    assert!(result.is_ok()); // ok, but never checks the file's contents
}

// Good: checks the actual observable effect.
#[test]
fn writes_output_file() -> std::io::Result<()> {
    write_report(&data, "/tmp/report.txt")?;
    let contents = std::fs::read_to_string("/tmp/report.txt")?;
    assert!(contents.contains("Total: 42"));
    Ok(())
}
```

## 14. Not testing generic/trait-object boundaries with more than one type

A generic function or trait tested against only one concrete implementor can pass while secretly depending on that implementor's quirks (e.g., a particular `Ord` tie-breaking behavior). Exercise at least two meaningfully different concrete types where practical.

## 15. Forgetting to wire up a new test module

When splitting a large inline `mod tests` into files (see `organization-and-structure.md`), it's easy to add a new file but forget the corresponding `mod new_file;` declaration. The file then silently isn't compiled or run — `cargo test` reports success with fewer tests than expected, not an error. After restructuring, check the total test count before and after with `cargo test -- --list` to confirm nothing went missing.
