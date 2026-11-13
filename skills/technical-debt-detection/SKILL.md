---
name: technical-debt-detection
description: Detect and report technical debt in a codebase. Use this skill whenever the user asks to find tech debt, review code quality, audit a repository, list code smells, or check for anti-patterns — in any language or framework. Also use it when the user asks for a code review that should flag maintainability risk, not just bugs.
---

# Technical Debt Detection

## Purpose

Find technical debt in source code. Report each finding with a location, a pattern name, and a fix.
This skill applies to all languages and all frameworks. The patterns are language-agnostic.

## Definition

Technical debt is the future cost of a past shortcut. A team picks a fast solution now.
The system pays interest later, as slower changes and higher bug risk.
Teams take on debt for speed. Debt becomes a problem only when no one repays it.

## Root Causes

Check for these causes. They explain why debt exists, not just where.

- Time pressure. The team skipped design or tests to hit a date.
- Unclear or changing requirements. The code was built for a spec that moved.
- Skill or knowledge gaps. The team did not know a better approach.
- Weak process. Reviews, refactoring, and planning did not happen.
- Ignored best practice. The team skipped tests, docs, or established standards.

## How to Use This List

1. Scan the code against each pattern below.
2. For each match, record the file, the line range, and the pattern name.
3. State the fix in one sentence.
4. Rank each finding: **High** (blocks changes or causes outages), **Medium** (slows development), **Low** (style or minor risk).
5. Do not report a pattern without a concrete location. A vague claim is not a finding.
6. Group the report by category, not by file.

## 1. Code-Level Smells

| Pattern | Definition | Signal | Example |
|---|---|---|---|
| Duplicate Code | The same logic exists in more than one place. | Copy-pasted blocks. Near-identical functions. | The same email-validation regex appears in three C# controllers. |
| Long Method | One function does too many things. | Function body over 50 lines. Many local variables. | A 300-line `ProcessOrder()` method in Java. |
| Large Class / God Object | One class holds too many responsibilities. | Class over 500 lines. Many unrelated methods. | A `Utils` or `Manager` class that every module imports. |
| Long Parameter List | A function takes too many parameters. | More than four parameters. Parameters that always travel together. | `create_user(name, email, age, address, phone, role)` in Python. |
| Deep Nesting | Code has many nested conditions or loops. | Indentation past four levels. | `if` inside `for` inside `try` inside `if` in a single method. |
| Magic Numbers / Strings | A raw literal controls logic, with no named meaning. | Bare numbers or strings inside conditions. | `if (status == 3)` instead of `if (status == OrderStatus.Shipped)`. |
| Dead Code | Code exists, but no path runs it. | Unreachable branches. Unused private methods. Unused feature flags. | An `if (false)` block left after a rollback. |
| Commented-Out Code | Old code is disabled with comments instead of removed. | Blocks of `//` or `#` lines with no explanation. | Old pricing logic left commented out "just in case." |
| Primitive Obsession | A primitive type stands in for a domain concept. | Raw strings for IDs, emails, or money. No validation at the type level. | `string email` instead of a validated `Email` type. |
| Data Clumps | The same group of fields or parameters always appears together. | Three or more parameters that repeat across many functions. | `street, city, zip` passed separately everywhere, instead of an `Address` type. |
| Feature Envy | A method uses another class's data more than its own. | A method calls many getters on one other object. | `OrderService` reaches into `Customer` internals to compute a discount. |
| Shotgun Surgery | One small change forces edits across many files. | A single feature change touches ten or more files. | Adding one field requires edits to the entity, DTO, mapper, and five services. |
| Divergent Change | One class changes for many unrelated reasons. | Git history shows unrelated features touching the same file. | `UserController` changes for billing, auth, and email alike. |

## 2. Architecture and Design Debt

| Pattern | Definition | Signal | Example |
|---|---|---|---|
| Tight Coupling | Modules depend on each other's internals, not on an interface. | Concrete class references. No dependency injection. | A service calls `new SqlRepository()` directly, instead of taking an `IRepository`. |
| Circular Dependency | Two or more modules depend on each other. | Import cycles. Build order errors. | `ModuleA` imports `ModuleB`, and `ModuleB` imports `ModuleA`. |
| Big Ball of Mud | The system has no defined structure or layers. | Any file can call any other file. No clear module boundaries. | UI code queries the database directly, with no service layer. |
| Anemic Domain Model | Domain objects hold data but no behavior. | Classes with only getters and setters. Logic lives in separate service classes. | An `Order` class with public properties and no methods. |
| Leaky Abstraction | An interface exposes details of its own implementation. | Callers must know internal details to use the interface correctly. | A repository interface that returns raw SQL result rows. |
| Missing Separation of Concerns | One layer mixes unrelated responsibilities. | Business rules inside a UI controller. SQL inside a view. | An ASP.NET controller that builds SQL strings by hand. |
| Overengineering | The design is more complex than the problem needs. | Interfaces with a single implementation. Deep inheritance for simple logic. | A factory-of-factories for a class with two subtypes. |
| Inconsistent Layering | Layers skip or bypass each other. | The UI calls the data layer directly, skipping business logic. | A React component that calls the database SDK directly. |
| Vendor Lock-In Without Abstraction | Business logic depends directly on one vendor's API. | No interface between business logic and a cloud or third-party SDK. | Domain code calls the AWS SDK directly, with no storage abstraction. |

## 3. Test Debt

| Pattern | Definition | Signal | Example |
|---|---|---|---|
| Missing or Low Coverage | Little or no automated test exists. | No test project. Coverage below team standard. | A payment module with zero unit tests. |
| Flaky Tests | A test passes or fails without a code change. | Reruns of the same suite give different results. | A test that depends on system time or a live network call. |
| Tests Coupled to Implementation | Tests break when internals change, though behavior is the same. | Tests mock every internal method call. | A test fails after a private method rename, though output is unchanged. |
| Manual-Only Testing | No automated regression suite exists. | A QA checklist exists, but no test suite runs it. | Release notes say "manually verified" for every build. |
| Slow Test Suite | The test suite takes too long to run. | Full suite runs over ten minutes. Developers skip it locally. | A unit test suite that connects to a live database. |

## 4. Dependency and Build Debt

| Pattern | Definition | Signal | Example |
|---|---|---|---|
| Outdated Dependencies | Libraries sit far behind their current stable version. | Package manager reports many outdated packages. | A .NET project still targets an end-of-life framework version. |
| Unpinned Versions | Dependency versions are not locked. | No lock file. Version ranges like `^1.0.0` in production. | An `npm` project with no `package-lock.json` committed. |
| Dependency Conflict | Two dependencies need incompatible versions of a third. | An update to one package breaks another. | Library A needs `X v1`. Library B needs `X v2`. |
| No CI/CD Pipeline | Builds and deploys are manual. | No automated build, test, or deploy pipeline. | A developer copies build output to a server by hand. |
| Environment Drift | Environments differ in undocumented ways. | "Works on my machine" bugs. No infrastructure as code. | Production has a package version that staging does not. |

## 5. Documentation and Knowledge Debt

| Pattern | Definition | Signal | Example |
|---|---|---|---|
| Missing or Outdated Docs | Documentation does not match current code. | A README that describes removed features. No API docs. | A setup guide that references a deleted config file. |
| Bus Factor Risk | Only one person understands a system. | One name appears on nearly all commits to a module. | Only one engineer can safely deploy the billing service. |
| Unresolved TODO / FIXME | A marker for future work is never done. | Old TODO comments with no ticket or owner. | `// TODO: fix this before launch`, three years old. |
| Poor or Inconsistent Naming | Names do not describe purpose. Conventions vary across the code. | Names like `data`, `temp`, `Manager2`. Mixed casing styles. | A method named `DoStuff()`. |

## 6. Reliability and Operations Debt

| Pattern | Definition | Signal | Example |
|---|---|---|---|
| Swallowed Exceptions | An error is caught and dropped, with no handling or log. | Empty `catch` blocks. Errors logged but never acted on. | `catch (Exception) { }` in C#, with no log and no rethrow. |
| Missing Observability | The system gives no insight into failures in production. | No structured logs, metrics, or traces. | A background job fails silently, with no alert. |
| Missing Input Validation | The system trusts external input without a check. | User input reaches logic or a query with no validation. | A SQL query built by string concatenation from user input. |
| Hardcoded Configuration or Secrets | Config values or credentials sit fixed in source code. | Connection strings or API keys written directly in code. | `var apiKey = "sk-12345"` committed to source control. |
| Resource Leak | Code opens a resource and never releases it on every path. | File handles, connections, or streams opened without `using`, `try-finally`, or `close`. | A database connection left open when an error path skips cleanup. |

## 7. Data and Performance Debt

| Pattern | Definition | Signal | Example |
|---|---|---|---|
| N+1 Query | Code runs one query per item, instead of one query for all items. | A loop that queries the database on each pass. | An ORM loads each order's line items inside a loop, one query per order. |
| No Migration Strategy | Schema changes are applied by hand. | No migration scripts. Manual `ALTER TABLE` on production. | A schema change applied directly through a database GUI tool. |
| Schema Drift | The live database schema no longer matches migration history. | A column exists in production but not in any migration file. | A hotfix column added by hand, never captured in source control. |
| Undocumented Denormalization | The same data is duplicated across tables, with no defined sync rule. | The same value stored in multiple places, with no clear owner. | A customer's name copied into every order row, never updated on rename. |

## 8. Process Debt

| Pattern | Definition | Signal | Example |
|---|---|---|---|
| Deferred Refactoring | Cleanup work is scheduled but never done. | A backlog of refactor tickets, none ever picked up. | A "refactor later" comment that outlives three product releases. |
| Escalation of Commitment | The team keeps investing in an approach that keeps failing. | Continued spend on a design despite repeated, similar problems. | A team patches the same broken module a fourth time, instead of replacing it. |
| Rushed Delivery | Shortcuts are taken under deadline pressure, with no plan to repay them. | Features merged with no review, test, or doc, right before a deadline. | Code merged to `main` with no review, right before a demo. |
| Tyranny of Small Decisions | Many small, safe-looking choices add up to a bad outcome. | No single change looks harmful, but the whole is unmanageable. | Ten small "quick fixes" that together create an untestable module. |

## Related Terms

Use these terms in reports. Keep the meaning consistent with this glossary.

- **Anti-pattern**: A common solution that looks reasonable but causes more harm than good.
- **Spaghetti code**: Code with tangled control flow and no clear structure.
- **Software rot**: The decline of a system's quality over time, from unmanaged change.
- **Software brittleness**: A system where small changes cause unrelated failures.
- **Sunk cost fallacy**: Continued investment in a failing approach, because of past spend.
- **Code smell**: A surface sign in code that suggests a deeper design problem.

## Source

Base definitions and root causes drawn from the Wikipedia article on [Technical debt](https://en.wikipedia.org/wiki/Technical_debt). Pattern catalog extends Martin Fowler's code smell catalog and common cross-language anti-patterns.
