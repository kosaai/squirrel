# Dime Income Data Migration Notes

## Additive model version

`IncomeModel.xcdatamodel` is a new current version of Squirrel's existing `DataContainer.xcdatamodeld`. It retains the prior `SpendingsModel.xcdatamodel` unchanged and adds only:

- `IncomeEntity`: UUID, EUR amount, comment, date, place, time-zone identifier, and one category relationship.
- `CategoryEntity.incomes`: an optional to-many relationship with cascade deletion, mirroring the existing category-to-expense relationship.

No `SpendingEntity`, `ReturnEntity`, existing category attribute, persistent-store URL, identifier, or record is altered. Existing expenses are not interpreted as income.

The new active model intentionally has no CloudKit configuration. `DataManager` continues using `NSPersistentContainer("DataContainer")` with automatic and inferred lightweight migration enabled.

## Local APIs

`IncomesModel.swift` adds local-only `CoreDataModel` APIs:

- `fetchIncomes(from:through:categoryID:in:)`
- `addIncome(_:timeZoneIdentifier:)`
- `editIncome(_:with:timeZoneIdentifier:)`
- `deleteIncome(_:)`

All writes enforce a positive amount, an existing category, and `currency = "EUR"`. Editing preserves the existing income UUID. Expense and return queries remain untouched because they fetch only their original entity types.

## Runtime validation still required

A device or simulator upgrade test with a copy of a pre-income local store is required before release to prove Core Data performs the inferred lightweight migration and retains all existing records. No runtime/build tooling was run in this task.
