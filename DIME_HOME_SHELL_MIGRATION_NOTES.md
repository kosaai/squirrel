# Dime Home Shell Migration Notes

## Source-to-destination map

| Dime source | Squirrel destination |
|---|---|
| `app/dime/Views/HomeView.swift` | `financecontrol/View/DimeShell/Views/HomeView.swift` |
| Dime `TabView` destination composition | `financecontrol/View/DimeShell/Views/DimeHomeDestinationView.swift` |
| Dime tab/presentation state | `financecontrol/View/DimeShell/Models/DimeHomeNavigationState.swift` |

## Adaptations

- Dime's `HomeView` ZStack, `TabView`, and custom tab-bar placement are retained. The shell composes the migrated local `DimeLogView`, then existing Squirrel `StatsView` and `SettingsView`.
- Dime `AppLockViewModel`, `OverallTransactionManager`, Dime toasts/confetti, CloudKit state, `DataController`, `TransactionView`, and delete-alert paths are not imported. They depend on Dime-only persistence or on features scheduled for later migration.
- Budget is deliberately excluded from `availableDestinations`; its Dime tab keeps its original visual slot but cannot navigate until its original destination exists. No placeholder screen is created.
- Add presentation is injected as a closure so a later Dime transaction editor can be connected without changing the shell or tab bar.
- The shell is intentionally not referenced from Squirrel `ContentView`; current Home navigation remains active.
