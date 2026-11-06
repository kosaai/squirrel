# Dime shell integration audit (Task 14)

## Findings and corrections

- **Unwired center action:** `DimeHomeView` accepted an external add closure and did not present the migrated editor. It now owns a `DimeTransactionView` sheet and routes the Dime custom-tab-bar + control to it.
- **Due schedule processing:** schedules were only processed from the inactive Log view. The shell now processes them on appearance and on foreground activation. The schedule ledger still guards schedule UUID/date generation.
- **Tab destinations:** static inspection confirms Log, Insights, Budget, and Settings resolve to `DimeLogView`, `DimeInsightsView`, `DimeBudgetView`, and `DimeSettingsView` respectively.
- **Settings environment:** the Settings adapter now supplies its required local `PrivacyMonitor`; `CoreDataModel` and `RatesViewModel` remain inherited from the eventual parent shell host.
- **Transaction routing:** Log row selection passes its typed record to `DimeTransactionView`; delete remains type-routed through `DimeLogDataAdapter`. The editor keeps templates as state-only application and prevents recurrence/future scheduling when editing an existing record.

## Static limitations

Core Data observation, nested Settings destinations, and scene-phase recurrence processing need runtime verification. No active production navigation was altered.
