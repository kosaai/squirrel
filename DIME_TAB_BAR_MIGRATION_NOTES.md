# Dime CustomTabBar Migration Notes

## Source-to-destination map

| Dime source | Squirrel destination |
|---|---|
| `app/dime/Views/CustomTabBar.swift` | `financecontrol/View/DimeShell/Views/CustomTabBar.swift` |
| Dime `TabButton` and `BouncyButton` | `financecontrol/View/DimeShell/Views/DimeTabButton.swift` |
| Dime centered add button and `MyButtonStyle` | `financecontrol/View/DimeShell/Views/DimeAddTransactionButton.swift` |
| Dime tab-name strings | `financecontrol/View/DimeShell/Models/DimeTabDestination.swift` |

## Adaptations

- Dime `String` tab selection is represented by the small `DimeTabDestination` enum. It retains Dime's `Log`, `Insights`, `Budget`, and `Settings` image names and provides one extension point for a future destination.
- The visual component receives selection and add-action bindings from a future shell. It does not present a transaction editor, route a screen, fetch Core Data, or contain business logic.
- Dime's empty-transaction pulse is supplied by the host through `shouldPulseAddButton`; this avoids importing Dime `Transaction`/`FetchRequest` while preserving the original animation.
- RTL reverses the semantic tab order while preserving Dime's centered add control and logical destination selection.
- Existing DimeShared colors and migrated tab icon assets are used without renaming. No packages, CloudKit, iCloud, or data-model changes are required.
