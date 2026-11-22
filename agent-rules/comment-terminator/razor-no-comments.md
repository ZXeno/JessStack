# Razor and Blazor comment rules

These rules add to the core rules in `comment-terminator.md`.

## Scope

- `.razor` and `.cshtml` files: `@* *@` Razor comments, `<!-- -->` HTML comments, and C# comments in `@code`, `@functions`, and `@{ }` blocks.
- `.razor.cs` code-behind files.
- `.razor.css` isolated style files: `/* */` comments.

Read `cs-no-comments.md` too. It applies to every C# block and to every `.razor.cs` file.

## Skip

Skip `*.razor.g.cs`, `*.cshtml.g.cs`, and everything under `obj/` and `bin/`. List each skipped file in skips.

## Walk away

- `///` on a `[Parameter]` or `[CascadingParameter]` property, an `EventCallback`, or a `public` method of a component in a Razor class library that another project references. It is the component's public API doc. In any other component it dies.

## Dies

- Commented-out markup and components, such as `@* <MyComponent /> *@` or `<!-- <div>...</div> -->`.
- In `.cshtml`, an HTML comment ships to the client in the rendered page. If it names internal detail, such as a server path, a table name, or a user, report the exposure next to the deletion.

## Suppressions

Every C# suppression form in `cs-no-comments.md` applies inside Razor files.

Delete `/* stylelint-disable */` and its matching `/* stylelint-enable */`, and `/* stylelint-disable-next-line */`, in `.razor.css` files.

Razor compiler warnings that catch real bugs die with a flag. Examples: `RZ10012` unknown component, `BL0005` a component parameter set outside the component, and `BL0007` a component parameter property with logic in its accessors.

## Tracing

Use the Roslyn navigator tools on the `.razor.cs` and generated component types: `find_references`, `find_callers`, and `get_symbol_source`. Fall back to Grep for markup.
