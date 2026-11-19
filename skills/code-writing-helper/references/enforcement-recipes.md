# Enforcement recipes

Use this file when you turn a correction into a check. Each recipe gives the tool, the configuration, and an error message that states the fix. Before you add a tool, look for the tool that the project already uses. Before you write a configuration, confirm the syntax for the installed tool version (`--help`, the tool's docs, or the existing configuration file).

Contents:

- Message rules
- TypeScript, JavaScript, Svelte
- Rust
- C# and .NET
- Python
- Fallback: a test that reads the source tree

## Message rules

Each message tells the agent what to do, not only what is wrong. Name the replacement and its location. If an exception exists, name where it is permitted.

- Weak: "useEffect is not allowed."
- Strong: "Raw useEffect is banned in product code. Use useSubscription from @app/hooks. Raw useEffect is permitted only in src/framework/."

## TypeScript, JavaScript, Svelte

ESLint flat configuration (`eslint.config.js`). `eslint-plugin-svelte` applies the same rules to `.svelte` files.

Ban a named import, a global, and a property:

```js
export default [
  {
    files: ["src/**/*.{ts,tsx,svelte}"],
    ignores: ["src/framework/**"],
    rules: {
      "no-restricted-imports": ["error", {
        paths: [{
          name: "react",
          importNames: ["useEffect"],
          message: "Raw useEffect is banned in product code. Use useSubscription from @app/hooks.",
        }],
      }],
      "no-restricted-globals": ["error", {
        name: "setTimeout",
        message: "Do not wait for a different part of the app with a timer. Fix the order of the update at its source.",
      }],
      "no-restricted-properties": ["error", {
        object: "window",
        property: "setTimeout",
        message: "Do not wait for a different part of the app with a timer. Fix the order of the update at its source.",
      }],
      "no-restricted-syntax": ["error", {
        selector: "MemberExpression[object.name='React'][property.name='useEffect']",
        message: "Raw useEffect is banned in product code. Use useSubscription from @app/hooks.",
      }],
    },
  },
];
```

`no-restricted-imports` does not catch `React.useEffect` through a namespace import. The `no-restricted-syntax` entry catches it.

Import boundary between directories, with `eslint-plugin-import`:

```js
"import/no-restricted-paths": ["error", {
  zones: [{
    target: "./src/electron-renderer",
    from: "./src/electron-main",
    message: "Renderer code must not import main-process code. Move shared code to src/shared/ or call the main process through IPC.",
  }],
}],
```

Import boundary with `dependency-cruiser` (`.dependency-cruiser.js`). The `comment` field appears in the output:

```js
module.exports = {
  forbidden: [{
    name: "renderer-not-to-main",
    comment: "Renderer code must not import main-process code. Move shared code to src/shared/.",
    severity: "error",
    from: { path: "^src/electron-renderer" },
    to: { path: "^src/electron-main" },
  }],
};
```

## Rust

Ban a method, a type, or a macro in `clippy.toml`. The `reason` appears in the diagnostic:

```toml
disallowed-methods = [
  { path = "std::thread::sleep", reason = "Wait on a channel or a Condvar for the event. Do not poll with sleep." },
]
disallowed-types = [
  { path = "std::sync::Mutex", reason = "Use parking_lot::Mutex." },
]
disallowed-macros = [
  { path = "std::dbg", reason = "Use tracing::debug!." },
]
```

Make the lints fail the build in `Cargo.toml`:

```toml
[lints.clippy]
disallowed_methods = "deny"
disallowed_types = "deny"
disallowed_macros = "deny"
```

Boundaries: put each layer in its own crate. Cargo then rejects an import from a crate that is not in `[dependencies]`. Use `pub(crate)` to keep items inside a crate.

## C# and .NET

Ban an API with `Microsoft.CodeAnalysis.BannedApiAnalyzers` (diagnostic `RS0030`):

```xml
<ItemGroup>
  <PackageReference Include="Microsoft.CodeAnalysis.BannedApiAnalyzers" Version="3.3.4" PrivateAssets="all" />
  <AdditionalFiles Include="BannedSymbols.txt" />
</ItemGroup>
```

`BannedSymbols.txt`. The text after `;` is the message:

```
M:System.Threading.Thread.Sleep(System.Int32);Await the event. In a background loop, use Task.Delay with a CancellationToken.
T:System.Net.WebClient;Use IHttpClientFactory.
```

Make the diagnostic an error in `.editorconfig`:

```ini
[*.cs]
dotnet_diagnostic.RS0030.severity = error
```

Boundaries: put each layer in its own project. A missing `ProjectReference` blocks the import at compile time. For namespace rules inside one assembly, add an architecture test with `NetArchTest.Rules`:

```csharp
[Fact]
public void Domain_does_not_depend_on_infrastructure()
{
    var result = Types.InAssembly(typeof(Order).Assembly)
        .That().ResideInNamespace("App.Domain")
        .ShouldNot().HaveDependencyOn("App.Infrastructure")
        .GetResult();

    Assert.True(result.IsSuccessful, "App.Domain must not reference App.Infrastructure. Put an interface in App.Domain and implement it in App.Infrastructure.");
}
```

## Python

Ban an import with Ruff rule `TID251` in `pyproject.toml`:

```toml
[tool.ruff.lint]
extend-select = ["TID251"]

[tool.ruff.lint.flake8-tidy-imports.banned-api]
"requests".msg = "Use httpx through app.http.client."
```

Import boundary with `import-linter` (run `lint-imports`):

```toml
[tool.importlinter]
root_package = "app"

[[tool.importlinter.contracts]]
name = "Domain does not import infrastructure. Put an interface in app.domain."
type = "forbidden"
source_modules = ["app.domain"]
forbidden_modules = ["app.infrastructure"]
```

## Fallback: a test that reads the source tree

If no linter can express the rule, write a test that reads the source files and fails on the pattern. The assertion message states the fix. Keep an explicit allowlist of the old violations in the test, and remove entries as the cleanup proceeds. This works in each language and runs with the normal test command.
