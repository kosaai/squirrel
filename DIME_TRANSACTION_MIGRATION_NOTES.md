# Dime Transaction Editor Migration Notes

| Dime source | Squirrel destination |
|---|---|
| `Views/TransactionView.swift` | `financecontrol/View/DimeTransaction/Views/TransactionView.swift` |
| `Components/Transactions/NumberPad.swift` | `financecontrol/View/DimeTransaction/Components/NumberPad.swift` |
| `Components/Transactions/SuggestedTransactions.swift` | `financecontrol/View/DimeTransaction/Components/SuggestedTransactions.swift` |
| `Components/Transactions/TransactionCategoryPicker.swift` | `financecontrol/View/DimeTransaction/Components/TransactionCategoryPicker.swift` |
| Dime transaction mutation/query calls | `financecontrol/View/DimeTransaction/ViewModels/DimeTransactionDataAdapter.swift` |

## Adaptations

- The editor writes EUR-only `SpendingEntityLocal` values through existing `CoreDataModel.addSpending` and `editSpending` APIs. Edit retains the target record identity and uses exchange rate `1` for EUR.
- Existing categories are fetched from Squirrel `CategoryEntity`; category labels and stored colors replace Dime-only emoji/order/income attributes.
- Suggestions reuse existing local spendings. The Dime number-pad cent-entry layout, button sizing, rounded typography, colors, and press animation are retained.
- Dime income, recurrence, template, future transaction, CloudKit/KVS, and Dime `DataController` paths are excluded because the current schema has no equivalent persistence fields. No data or controls are fabricated.
- The editor is registered but not presented by Squirrel `ContentView` or the inactive Dime shell.
