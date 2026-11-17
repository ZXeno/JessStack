---
paths:
  - "**/*.razor"
  - "**/*.cs"
  - "**/*.csproj"
---

You output C# that conforms to ALL rules below. These are mandatory, not suggestions. These rules supercede all other C# related coding style rulesets or skill recommendations, without exception.

# C# Coding Style — Output Rules

**GLOBAL RULE:** NEVER add perfunctory whitespace to align code by the `=` character (or any other token) under any circumstance.

## 1. Naming

- Names are meaningful and descriptive. No abbreviations or single-letter names except iterative variables (use judgment).
- **PascalCase:** classes, structs, enums, enum values, methods, properties, constants, public properties, static/readonly fields.
- **camelCase:** local variables, method parameters, private/internal fields.
- Prefix class-scoped fields with `_` (e.g. `_myService`, `_value`).
- Classes: PascalCase nouns (`Customer`, `Invoice`).
- Interfaces: PascalCase prefixed with `I` (`ICustomerRepository`, `IDisposable`).
- Methods: PascalCase verbs (`CalculateTotal`, `SaveChanges`).
- Async methods: PascalCase verbs suffixed `Async` (`CalculateTotalAsync`, `SaveChangesAsync`).
- Properties: PascalCase nouns/adjectives (`FirstName`, `IsEnabled`).
- Variables/parameters: camelCase (`employeeList`, `maximumValue`).
- Constants: PascalCase nouns/adjectives (`MaxBufferSize`, `DefaultTimeout`).
- Enum values: PascalCase (`StatusCode.Ok`, `StatusCode.Error`).
- **Do NOT put parameter names in method names.** ❌ `GetMyObjectByQueryParameterAsync(string queryParameter)` → ✅ `GetMyObjectAsync(string queryParameter)`.
- **Acronyms:** PascalCase — first letter capital, rest lowercase (`GetAod`, `Last4Ssn`). Avoid acronyms that aren't contextually obvious or well-known. Two-letter acronyms may be all-uppercase (`US`, `IO`, `QA`, `IT`).

### Collections
- Use plural/purpose-indicating names. camelCase for locals/params/private fields; PascalCase for public properties, constants, static/readonly fields.
- Add a clarifying suffix when helpful: `Array` for arrays, `List` for lists, `Dictionary` or `Map` for dictionaries.
- Examples: `List<User> users`, `Dictionary<int, string> productIdToNameMap`, `string[] fileLines`, `HashSet<Employee> uniqueEmployees`.

## 2. File Organization

- Separate files by purpose/functionality (apply BDD, DDD, Single Responsibility where appropriate).
- One class/interface/type per file, UNLESS the type is scoped to the enclosing class (e.g. a struct representing specific query results).
- File name matches the type name + `.cs` (`Customer.cs`, `ICustomerRepository.cs`).
- Organize into folders/namespaces by purpose (`Models`, `Repositories`, `Controllers`).
- Shared enums live in their own file `<EnumName>.cs` (`EmailStatusCodes.cs`), preferably under a shared `Enums` directory.

### Class member order
1. Constants
2. Fields (static, then instance)
3. Constructors
4. Properties (auto-properties first)
5. Methods (grouped by access level, then by functionality)

Within this: separate each group with ONE blank line. Group by access modifier in the order **public, protected, internal, private**. Place interface implementations after constructors and before other members.

```csharp
public class MyClass
{
    private const int MaxBufferSize = 1024;

    private static int _instanceCount;
    private readonly IMyService _myService;
    private int _value;

    public MyClass()
    {
        // Constructor logic
    }

    public MyClass(
        int value,
        string otherValue,
        IMyService myService)
    {
        // Constructor logic
    }

    public static int InstanceCount => _instanceCount;

    public string PropertyTwo { get; set; }

    public int MyProperty
    {
        get => _value;
        set => _value = value;
    }

    public void DoSomething()
    {
        // Method logic
    }

    protected void ProtectedMethod()
    {
        // Method logic
    }

    private void HelperMethod()
    {
        // Method logic
    }
}
```

## 3. Indentation & Cyclomatic Complexity

- Prefer vertical formatting + indentation over long horizontal lines for complex code; it improves readability and comprehension.
- For complex conditionals, break across lines — each indentation level signals a new conditional context, one condition per line:

```csharp
if (stateOptions.IsLocal
    && (stateOptions.ShowLocalData
        || stateOptions.Local
        || stateOptions.NetworkLocal
        || stateOptions.PhysicallyConnected))
{
    return true;
}
```

- Distinguish stylistic indentation (formatting for readability — fine) from functional indentation (execution-tree depth = cyclomatic complexity — minimize).
- **Reduce cyclomatic complexity:** invert `if` statements to reduce nesting; combine conditionals where possible; remove unnecessary `else`; replace `if`/`elseif`/`else` chains with `switch` statements/expressions where possible.
- Prefer early-exit: guard clauses, success checks, early returns. Avoid `if`/`else` trees and nested logic trees (each branch adds a required test and hides bugs).
- Avoid more than 4 levels of functional indentation. Each functional indentation level should be a genuine new logical branch, preferring early exit over deeper context.
- Don't place large functional blocks inside `if` bodies — invert the condition and exit early instead.

```csharp
// Prefer early-exit / guard clauses over nesting:
public static string MyMethod()
{
    if (!condition1 && condition2)
    {
        return "Result1";
    }

    if (condition2)
    {
        return "Result2";
    }

    string result = string.Empty;
    if (condition3)
    {
        result = "Result3";
    }

    if (condition4)
    {
        result += "MyChanges";
    }

    return result;
}
```

## 4. Curly Braces

- **Allman style** for control structures, methods, classes, and properties: opening brace on its OWN new line; closing brace on its own line aligned with the opener.
- ALWAYS use braces for `if`, `else`, `for`, `while`, `do` — even for a single statement. No one-liners without braces.
- ALWAYS follow a control structure's closing brace with a blank line.

```csharp
if (condition)
{
    // do stuff
}
else
{
    // do condition 2 stuff
}

while (condition)
{
    // stuff here
}
```

## 5. Spacing

- Tabs are 4 whitespace characters.
- Single space between keywords, operators, and parentheses.
- NO padding spaces inside `()` or `[]` — ❌ `( object myParam )`, ❌ `[ "value" ]`. Extra spaces inside `{}` are fine — ✅ `new() { PropertyA = "value" }`.
- Single space after a comma or semicolon in a single-line list.
- Single blank line to separate logical groups within a method or property.
- A closing `}` that ends a logical block is followed by a blank line.
- Single blank line between constructors, methods, properties, and groups of field declarations. Individual fields need no blank line between each.

## 6. Line Length

- Limit lines to ~120 characters including whitespace.
- Break long statements across multiple lines (a list reads faster than a paragraph).
- When parameters span multiple lines, put exactly ONE parameter per line.
- Exempt from line-length limits: logging message templates, email templates, and other string literal definitions (splitting them hurts readability and causes avoidable allocations).

## 7. Comments

- XML comments (`///`) for public classes, interfaces, enums, methods, and properties.
- Single-line `//` comments for inline explanations and temporary code.
- Temporary/disabled code MUST include a date and an explanation of when/why. Remove commented-out code lacking a description and date.
- Keep comments concise and relevant. Update or remove comments when the related code changes or becomes outdated.

## 8. Practices

- Always use file-scoped namespaces. E.g.: `namespace Jarvis.Sys.Infra.ApplicationService;`
- Mark classes as `sealed` that do not have inheritors. In practice, this should result in most classes being sealed.
- *Never* use primary constructors, as they cannot be marked readonly.
- Mark methods `internal` or `private` by default, and only use `public` when necessary.
- Use collection expressions where possible (i.e. `List<string> myStrings = [];`). Use constructor calls when the number of items already known (i.e. `List<string> userIds = new(results.Count);`).
- Use pattern-matching over if-else chains.
- *Always* favor explicit types over `var`.


### Clean-as-you-code
When editing code unlikely to conflict with others' active work, make small improvements. Favor known performance wins, e.g.:
- Don't wrap a synchronous DB call in `await Task.FromResult(...)` inside an `async` method — use the true async variant (`SingleOrDefaultAsync()`).
- Add `.AsNoTracking()` to read-only EF Core queries.
- Return values directly.

```csharp
public async Task<Guid?> GetPersonId(int personGuid)
{
    return await (from ah in _dbContext.AccountHistogram.AsNoTracking()
        join a in _dbContext.Account.AsNoTracking() on ah.FkAccountId equals a.AccountId
        where ah.PersonGuid == personGuid
        select a.PersonId)
    .SingleOrDefaultAsync();
}
```

Small improvements compound into significant gains in performance, cost, and SLA compliance.

### Design principles
Apply (not as hard rules) Locality of Behavior, Domain-Driven Design, Single-Responsibility Principle, Abstraction, and Dependency Injection / Inversion of Control to keep classes/services small, testable, maintainable, and efficient.
