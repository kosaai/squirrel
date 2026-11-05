# Dime Log Migration Notes

## Source-to-destination map

| Dime source | Squirrel destination |
|---|---|
| `app/dime/Views/LogView.swift` | `financecontrol/View/Home/Views/DimeLog/LogView.swift` |
| Log filter/time/category picker views in `LogView.swift` | `financecontrol/View/Home/Views/DimeLog/DimeLogFilters.swift` |
| Log list, search, empty-state, and transaction-row views in `LogView.swift` | `financecontrol/View/Home/Views/DimeLog/DimeLogRows.swift` |
| Dime `DataController` Log query contract | `financecontrol/View/Home/ViewModels/DimeLog/DimeLogDataAdapter.swift` |

## Required adaptations

- The copied hierarchy uses `SpendingEntity`, `CategoryEntity`, `amountWithReturns`, `comment`, `place`, and Squirrel's existing `deleteSpending(_:)` API. Dime `Transaction`, `Category`, and `DataController` were not imported.
- Dime CloudKit sync monitoring, iCloud KVS checks, recurring/upcoming transactions, templates, income filtering, and CloudKit-driven refresh paths were omitted because Squirrel's current schema has no equivalent local fields. No substitute data is generated.
- Dime's popover layout is preserved with SwiftUI's built-in `.popover`; `Popovers` is therefore not yet required. The migrated search view has no UIKit autofocus hook, so `SwiftUI-Introspect` is also deferred until the original focus behavior is integrated.
- Amounts are displayed in EUR. Stored amounts, currencies, Core Data entities, and existing records are not changed.
- Dime's physical right-swipe delete was adapted to the semantic trailing edge using `layoutDirection`, preserving correct RTL deletion gestures.
- User-visible Log strings were added to `Localizable.xcstrings` in English and Arabic using `Dime Log …` keys.

## Not activated

`DimeLogView` is registered and compiled but is not referenced by Squirrel's active `HomeView`. Custom tab bar and Dime transaction editor migration remain separate tasks.
