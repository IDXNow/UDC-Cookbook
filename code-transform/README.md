# Code Transform Recipes

This category focuses on repeatable code-to-code changes where consistency matters more than one-off manual edits. We use these recipes to apply structural transformations across many files with predictable output.

These patterns are useful when teams need to evolve SQL or other code assets at scale without introducing drift between environments.

## Recipes

| Recipe | Description |
|---|---|
| [sql-view-customer-join/](sql-view-customer-join/) | Add customer name lookup to SQL views via INNER JOIN to d_customer |

## Common Use Cases

- SQL view federation across databases
- Adding inline comments to uncommented SQL
