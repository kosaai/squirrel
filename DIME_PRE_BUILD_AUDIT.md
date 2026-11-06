# Dime pre-build readiness audit

**Audit date:** 2026-11-06
**Branch / required baseline:** `dime-full-migration` / `19be411`
**Recommendation:** **READY FOR RUNTIME TESTING** — with the runtime gates listed below. This is not a compilation or migration-runtime claim.

## 1. Repository and integration

The required commit is an ancestor of the audited branch and the tree was clean before this audit. Reviewed: `DIME_MIGRATION_PLAN.md`, all `DIME_*_MIGRATION_NOTES.md`, `DIME_INTEGRATION_AUDIT.md`, Dime modules, adapters, and Xcode registration.

The inactive shell resolves all four tabs in `financecontrol/View/DimeShell/Views/DimeHomeDestinationView.swift`: Log, Insights, Budget, and Settings. `financecontrol/View/DimeShell/Views/HomeView.swift` now presents `DimeTransactionView` from the central button and processes due schedules on appearance/foreground. `financecontrol/View/ContentView.swift` was not changed and does not reference `DimeHomeView`.

## 2. Core Data migration safety

Verified ordered model chain and additive entities:

1. `SpendingsModel.xcdatamodel`: Category, Spending, Return.
2. `IncomeModel.xcdatamodel`: adds Income.
3. `ScheduledTransactionsModel.xcdatamodel`: adds ScheduledTransaction and ScheduledOccurrence.
4. `TemplatesModel.xcdatamodel`: adds TransactionTemplate.
5. `BudgetsModel.xcdatamodel`: adds DimeBudget; it is the Xcode current version.

Static XML checks found all previous entities retained at every successor and every relationship destination present in that version. `DataManager.swift` keeps `NSPersistentContainer("DataContainer")`, automatic migration, and inferred mapping enabled. No reset/destructive recovery path was found. Existing Spending, Category, and Return definitions remain in the original model version.

**Runtime gate:** inferred lightweight migration of a copied pre-income/pre-schedule store remains unverified and must be exercised before release. Category deletion behavior for new optional unidirectional template/budget relationships also requires runtime testing.

## 3. Swift readiness findings

Corrected explicit `Hashable` conformance for state-compared enums in:

- `DimeTransactionDataAdapter.Kind`
- `DimeInsightsDataAdapter.Period`
- `DimeLogSummary`

Corrected the missing original Dime empty-state asset at `financecontrol/Assets.xcassets/DimeShared/chart.imageset`.

Corrected dynamic recurrence wording to use the localized `Dime Recurring Every` key rather than fabricated interpolated keys in `DimeRecurringPicker.swift` and `TransactionView.swift`.

All migrated Swift basenames are registered in `Squirrel.xcodeproj/project.pbxproj`; static localization JSON and project/model references validate. No build was performed, so type checking, SDK availability, asset compilation, and environment-object resolution are still runtime/build gates.

## 4. Financial logic and recurrence

- Log, Budget, and Insights derive expense values from `SpendingEntity.amountWithReturns`.
- Income is separate through `IncomeEntity`; net is income minus expense.
- Future schedules are not fetched by completed-record analytics; generated occurrences create one completed record.
- `ScheduledTransactionsModel.swift` checks `scheduleID` and `scheduledDate` before generation. It advances day/week/month with `Calendar` APIs.
- Templates apply only editor state and explicitly reset recurrence; they do not create completed records.

**Runtime gates:** concurrency around schedule generation, app foreground behavior, month-end/DST handling, and actual Core Data notifications must be tested. Static inspection cannot prove no duplicate insertion across concurrent contexts.

## 5. UI fidelity, navigation, Arabic, and RTL

Original mappings are documented in the module notes. Directly migrated/derived Dime components include the custom tab bar, number pad, category picker, transaction/template editor controls, recurrence controls, Log structures, Insights custom-bar language, Budget cards/edit flow, and Settings grouped rows.

Known compatibility differences: Budget, Insights, and Settings use local adapters and selective Dime-derived components rather than every original Dime subview, because original dependencies/services (Cloud sync, multi-currency, or Dime DataController) are intentionally unavailable. These differences are documented, not presented as unsupported working features.

The custom tab bar reverses destination ordering under RTL and Log mirrors swipe edge. Static Dime localization-key scanning passed after the recurrence-key correction. Arabic currency/graph layout, native picker behavior, accessibility announcements, and all dynamic labels need runtime review.

## 6. Security and production safety

No CloudKit, persistent CloudKit container, KVS sync, or remote/exchange-rate reference was introduced in migrated Dime modules. No active production view, Core Data store URL, App Group identity, widget code, application name, or icon configuration was changed during this audit.

## Required Task 15.2 runtime tests

1. Build/type-check all targets.
2. Open copies of stores from every prior model version and verify inferred migration/data retention.
3. Exercise expense/income add, edit, delete, returns, templates, schedules, future due generation, cancellation, and foreground re-entry.
4. Confirm Log/Insights/Budget refresh after each mutation.
5. Test Dime shell editor presentation and all four tabs with inherited environment objects.
6. Test category deletion with income/template/budget/schedule references.
7. Test Arabic/RTL, Dynamic Type, asset rendering, and accessibility.
8. Test week/month/year boundaries and DST recurrence.
