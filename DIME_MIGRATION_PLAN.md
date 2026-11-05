# Dime → نفقات Full Source Migration Plan

**Prepared:** 2026-11-05
**Target branch:** `dime-full-migration`
**Dime source reviewed:** `rafsoh/dimeApp` `0463cb8caba237de781ae02e70a2ec82ae900c67`
**Squirrel base reviewed:** `origin/main` `1c47cbdf465ac444a4fdb7b367ef06411f355f10`

## Scope and non-negotiable boundaries

This is a direct migration of Dime's SwiftUI source hierarchy and behavior. New UI must be created by copying Dime source files into corresponding Squirrel feature folders, then making the smallest changes required for local Core Data, EUR-only policy, Arabic strings, RTL, and Squirrel integration. It is not a visual recreation.

The migration must retain Squirrel's `DataContainer` store name and existing store URL, entities, UUIDs, category relationships, App Group (`group.dev.squirrelapp.squirrel`), WidgetKit target, Arabic name `نفقات`, existing icon, backup/import/export, and existing data. It must not enable CloudKit, iCloud KVS, push notifications, an exchange-rate API, or non-EUR selection for newly created transactions.

### Legal gate — resolve before copying source

Dime's repository `LICENSE` is GNU GPL version 3. Copying or adapting its Swift sources creates a GPL-covered derivative work. Before implementation, obtain a compatible distribution decision: publish the combined application under GPLv3 with complete corresponding source and notices, or obtain separate written permission/license from the relevant copyright holders. Do not begin source copying until this gate is accepted.

## Verified feature inventory

| Dime feature | Principal Dime source | Target state in نفقات |
|---|---|---|
| App shell and original four-tab UI | `ContentView.swift`, `Views/HomeView.swift`, `Views/CustomTabBar.swift` | Migrate hierarchy; route tabs to migrated Log, Insights, Budget, and Settings modules. |
| Expense and income entry/editing | `Views/TransactionView.swift`, transaction components | Add first-class transaction kind to Squirrel; retain existing expense and return semantics. |
| Log, search, filters, grouped rows, delete/undo, photo share | `Views/LogView.swift`, `Views/SingleTransactionPhotoView.swift` | Migrate source with local fetch/query adapters. |
| Recurring transactions and templates | `Views/TemplateTransactionView.swift`, `Data/DataController.swift` | Add local recurrence/template entities and foreground processing; no sync dependency. |
| Budget limits and detailed budgets | `Views/BudgetView.swift`, `Views/NewBudgetView.swift` | Add category and overall budget entities; derive spend from local transactions. |
| Insights, summaries, charts, category drill-down | `Views/InsightsView.swift`, `Views/LineGraph.swift` | Migrate Dime views and derive data from Squirrel's local store. Existing Stats modules remain until replacement is verified. |
| Categories | `Views/CategoryView.swift` | Extend Squirrel category metadata for Dime emoji/order/kind, while retaining existing category fields. |
| Settings, notifications, visual preferences | `Views/Settings/*` | Migrate local-only settings selectively; omit Cloud and currency-selector routes. |
| App intents/shortcuts | `Shortcuts/*` | Adapt after local transaction/budget APIs exist; preserve Squirrel App Group and EUR-only creation. |
| Widgets | `ExpenditureWidgetExtension/*` plus `DataController` widget queries | Do not import Dime widget target or group. Extend Squirrel's existing widgets only after data-model migration. |

## Source and destination map

“Copy/adapt” means retain Dime's separate file/component hierarchy. “Do not copy” identifies code incompatible with the local-only target.

### App shell and shared infrastructure

| Dime file | Planned Squirrel location | Action / dependency |
|---|---|---|
| `dimeApp.swift` | `financecontrol/financecontrolApp.swift` | Adapt app dependency injection only; retain Squirrel app/scene lifecycle. |
| `ContentView.swift` | `financecontrol/View/ContentView.swift` | Adapt shell routing, onboarding, scene actions, and local preferences; remove Dime Cloud/KVS migrations. |
| `Views/HomeView.swift` | `financecontrol/View/DimeShell/Views/HomeView.swift` | Copy/adapt four-tab container, edit/delete overlay, toast state, and URL routing. |
| `Views/CustomTabBar.swift` | `financecontrol/View/DimeShell/Views/CustomTabBar.swift` | Copy/adapt exact tab/add animation; connect local transaction editor. |
| `Utilities/Color.swift` | `financecontrol/View/DimeShared/Color.swift` | Copy required `Color` API, backed by Dime-named copied assets; avoid colliding with existing extensions. |
| `Utilities/FontExtension.swift` | `financecontrol/View/DimeShared/FontExtension.swift` | Copy rounded-font/dynamic-type helpers. |
| `Utilities/DynamicType.swift` | `financecontrol/View/DimeShared/DynamicType.swift` | Copy/adapt. |
| `Utilities/ViewExtension.swift` | `financecontrol/View/DimeShared/ViewExtension.swift` | Copy only modifiers used by migrated files; replace Dime appearance storage with local Squirrel keys. |
| `Utilities/AlertToast.swift` | `financecontrol/View/DimeShared/AlertToast.swift` | Copy if Dime toast behavior is retained. |
| `Utilities/TabBarHiding.swift` | `financecontrol/View/DimeShared/TabBarHiding.swift` | Copy/adapt for the Dime custom tab bar. |
| `Utilities/Authentication.swift`, `Views/UnlockManager.swift` | `financecontrol/View/DimeShared/AppLock/` | Optional local app-lock feature; use no cloud service. |
| `Utilities/BottomSheet.swift`, `OffsetHelper.swift`, `KeyboardHeightHelper.swift`, `TestDragToAdd.swift`, `Wiggle.swift` | `financecontrol/View/DimeShared/` | Copy only where referenced by the final migrated Dime files. |
| `Utilities/AppVersion.swift`, `EmailExtensions.swift`, `SKProduct-LocalizedPrice.swift`, `StringExtension.swift`, `URLExtension.swift` | Existing equivalent or `DimeShared/` | Audit per call site; preserve Squirrel URLs/support identity. No Dime purchase/service endpoint migration. |
| `AppDelegate.swift`, `SceneDelegate.swift`, `SceneDelegate~.swift` | No direct destination | Do not copy: retain Squirrel lifecycle and target configuration. |

### Log, transactions, search, filters, and charts

| Dime file | Planned Squirrel location | Action / dependency |
|---|---|---|
| `Views/LogView.swift` | `financecontrol/View/DimeLog/Views/LogView.swift` | Copy/adapt as the original Home/Log hierarchy. Split only along Dime's existing nested view boundaries when extracting adapters; do not flatten it. |
| `Views/LineGraph.swift` | `financecontrol/View/DimeLog/Views/LineGraph.swift` | Copy/adapt; feed local `DimeLineGraphDataPoint` query results. |
| `Views/SingleTransactionPhotoView.swift` | `financecontrol/View/DimeLog/Views/SingleTransactionPhotoView.swift` | Copy/adapt for context-menu photo export. |
| `Models/FilterType.swift` | `financecontrol/View/DimeLog/Models/FilterType.swift` | Copy/adapt localized labels and unsupported-filter availability. |
| `Models/Line.swift` | `financecontrol/View/DimeShared/Shapes/Line.swift` | Copy/adapt, avoiding collision with existing `Universal/Shapes/Line.swift`. |
| `Components/Buttons/StepperButtons.swift` | `financecontrol/View/DimeLog/Components/StepperButtons.swift` | Copy/adapt for category/date/week/month filters. |
| `Views/TransactionView.swift` | `financecontrol/View/DimeTransactions/Views/TransactionView.swift` | Copy/adapt after transaction schema stage. |
| `Views/TemplateTransactionView.swift` | `financecontrol/View/DimeTransactions/Views/TemplateTransactionView.swift` | Copy/adapt after template schema/API stage. |
| `Components/Transactions/NumberPad.swift` | `financecontrol/View/DimeTransactions/Components/NumberPad.swift` | Copy/adapt for Dime amount-entry behavior. |
| `Components/Transactions/SuggestedTransactions.swift` | `financecontrol/View/DimeTransactions/Components/SuggestedTransactions.swift` | Copy/adapt to local recent-transaction queries. |
| `Components/Transactions/TransactionCategoryPicker.swift` | `financecontrol/View/DimeTransactions/Components/TransactionCategoryPicker.swift` | Copy/adapt to Squirrel category kind/order/emoji fields. |
| `Data/Helper.swift` | `financecontrol/Data/CoreData/DimeAdapters.swift` | Reimplement equivalent display helpers for new Squirrel entities. Never import Dime entity classes. |
| `Data/DataController.swift` | `financecontrol/Data/CoreData/DimeDataController.swift` | Do not copy container setup. Rebuild only query/mutation APIs against Squirrel's `CoreDataModel` and its local `NSPersistentContainer`. |
| `Models/TimeFrame.swift`, `ChartTimeFrame.swift` | `financecontrol/View/DimeLog/Models/` and `DimeInsights/Models/` | Copy/adapt enum names/Arabic display labels. |

### Insights, budgets, and categories

| Dime file | Planned Squirrel location | Action / dependency |
|---|---|---|
| `Views/InsightsView.swift` | `financecontrol/View/DimeInsights/Views/InsightsView.swift` | Copy/adapt after local aggregate query APIs are tested. |
| `Components/Buttons/InsightsSummaryBlock.swift` | `financecontrol/View/DimeInsights/Components/InsightsSummaryBlock.swift` | Copy/adapt. |
| `Views/BudgetView.swift` | `financecontrol/View/DimeBudget/Views/BudgetView.swift` | Copy/adapt after budget entities and calculations exist. |
| `Views/NewBudgetView.swift` | `financecontrol/View/DimeBudget/Views/NewBudgetView.swift` | Copy/adapt local budget create/edit flows. |
| `Components/Buttons/DetailedBudgetViewTopBarButtons.swift` | `financecontrol/View/DimeBudget/Components/DetailedBudgetViewTopBarButtons.swift` | Copy/adapt. |
| `Views/Shapes/DonutSemicircle.swift`, `Ring.swift`, `RoundedTriangle.swift`, `CustomCapsule.swift`, `PencilShape.swift` | `financecontrol/View/DimeShared/Shapes/` | Copy/adapt; retain Dime drawing/animation code. |
| `Models/BudgetTimeFrame.swift`, `PowerCategory.swift` | `financecontrol/View/DimeBudget/Models/` | Copy/adapt. |
| `Views/CategoryView.swift` | `financecontrol/View/DimeCategories/Views/CategoryView.swift` | Copy/adapt after category metadata migration. Keep current category screens available until data parity is confirmed. |
| `Models/CategoryCreationErrors.swift` | `financecontrol/View/DimeCategories/Models/CategoryCreationErrors.swift` | Copy/adapt to local validation rules. |

### Settings, onboarding, ancillary flows, shortcuts, and widgets

| Dime file or directory | Planned Squirrel location | Action / dependency |
|---|---|---|
| `Views/Settings/SettingsView.swift` | `financecontrol/View/DimeSettings/Views/SettingsView.swift` | Copy/adapt settings shell after core features; keep local-only sections. |
| `SettingsAppearanceView.swift`, `SettingsAppIconView.swift`, `SettingsFeatureLabView.swift`, `SettingsHapticsView.swift`, `SettingsNumberEntryView.swift`, `SettingsSubviewModifier.swift`, `SettingsUpcomingView.swift`, `SettingsWeekStartView.swift` | `financecontrol/View/DimeSettings/Views/` | Copy/adapt to Squirrel local defaults and Arabic strings. |
| `SettingsNotificationView.swift` | `financecontrol/View/DimeSettings/Views/SettingsNotificationView.swift` | Optional local-notification implementation; permission and reminders need device validation. |
| `SettingsEraseView.swift` | `financecontrol/View/DimeSettings/Views/SettingsEraseView.swift` | Adapt to Squirrel store and backup safeguards; never silently delete user records. |
| `SettingsCurrencyView.swift` | No direct destination | Do not copy: EUR is fixed. Replace only its necessary display formatting with a non-editable EUR setting. |
| `SettingsCloudView.swift` | No destination | Do not copy. |
| `Views/ImportDataView.swift` | Evaluate against existing `ExportAndBackupView` | Do not overwrite Squirrel import/export until formats and data safety are verified. |
| `Views/WelcomeSheetView.swift`, `UpdateSheet.swift` | `financecontrol/View/DimeSettings/` or existing onboarding | Adapt only if still needed; do not restore iCloud onboarding. |
| `Components/Toolbar/{BackButton,Toast,ToolbarButton,Toolbar}.swift` | `financecontrol/View/DimeShared/Toolbar/` | Copy/adapt where Dime screens reference them. |
| `Components/Buttons/{AlertButtons,SettingsBackButton}.swift` | `financecontrol/View/DimeShared/Buttons/` | Copy/adapt. |
| `Shortcuts/ShortcutsEntities.swift`, `ShortcutsProvider.swift`, `Shortcuts/Actions/*.swift` | `financecontrol/Shortcuts/` | Copy/adapt only after entities/data APIs exist; enforce EUR-only and local persistence. |
| `ExpenditureWidgetExtension` and intent targets | Existing `financecontrolWidget` target | Do not copy target, entitlements, or group. Later adapt the existing Squirrel widget providers to the expanded local schema. |
| `BudgetIntent`, `BudgetIntentUI` | Existing app intent architecture or no destination | Evaluate after budgets exist; do not add separate Dime targets unless required. |

## Assets and packages

### Copy only required Dime assets

- Color assets: `Colors/*`, `CategoryColors/*`, `Gradient/*`, `Percentage/*`, `ImportColors/*`, and settings colours used by migrated screens.
- Icons: the referenced `Icons/*` and all `TabBarIcons/*` needed by Dime's custom bar and source views.
- Do not copy Dime `AppIcon*.appiconset`, Dime branding assets, Dime entitlements, or App Group identifiers.
- Preserve `financecontrol/Assets.xcassets/AppIcon.appiconset` and Squirrel’s existing asset names. Namespace copied Dime assets if a collision occurs, then update only copied Dime call sites.

### Package assessment

| Dime package | Version in Dime project | Migration decision |
|---|---:|---|
| Popovers | `>= 1.0.0` | Required for faithful Dime filter/timeframe popovers. Add after license/version compatibility review. |
| SwiftUI-Introspect | `>= 1.0.0` | Required for Dime Search autofocus; add after compatibility review. |
| ConfettiSwiftUI | `>= 1.0.0` | Required only for exact Dime confetti behavior in the custom tab shell. |
| CrookedText | `>= 0.0.1` | Add only if an audited migrated source file uses it. |
| IsScrolling | `>= 1.1.2` | Not used by active Dime Log implementation; do not add unless a retained feature requires it. |
| Alamofire | `>= 5.8.0` | Do not add; no needed local-only feature requires it. |
| CloudKitSyncMonitor | `>= 1.2.1` | Do not add; prohibited CloudKit dependency. |

All package licenses and current iOS 15/Xcode compatibility must be recorded before addition.

## Safe Core Data extension plan

### Existing schema that must remain intact

`DataContainer` currently contains `SpendingEntity`, `CategoryEntity`, and `ReturnEntity`. Existing attributes, relationships, entity names, UUIDs, existing records, and persistent-store location must not be renamed, deleted, reset, or converted. `amountUSD` stays for legacy compatibility; no conversion is performed.

### Additive schema version

Create a new version of Squirrel’s existing `DataContainer.xcdatamodeld`, retaining the old version unchanged. Use lightweight migration only after confirming Xcode generates a compatible mapping. Add optional attributes with safe defaults and new entities/relationships only.

1. **CategoryEntity additions:** `emoji: String?`, `kindRaw: Int16` (expense/income), `sortOrder: Int64`, `createdAt: Date?`. Existing categories default to expense kind and retain their existing `color`, favorite, and shadowed state.
2. **SpendingEntity additions:** `transactionKindRaw: Int16` (expense/income), `day: Date?`, `month: Date?`, `recurrenceRuleRaw: Int16`, `recurrenceInterval: Int16`, `isOneOffGeneratedRecurring: Bool`, and an optional template relationship. Existing spendings default to expense/non-recurring. Populate derived day/month only for new/edited records or through an explicit, idempotent local migration—not by changing amount/currency/category data.
3. **TemplateTransactionEntity:** UUID, amount, comment/note, transaction kind, order, recurrence data, category relationship, timestamps.
4. **BudgetEntity:** UUID, amount, start date, timeframe, category relationship, created date, state/colour fields required by Dime. One category budget at most where Dime requires it.
5. **MainBudgetEntity:** amount, start date, timeframe, status/colour fields required by Dime, preserving Dime's one-overall-budget behavior in local API validation.

Transactions remain expenses by default. Income must be represented by the additive `transactionKindRaw`; it must not overload returns, use negative values, or change the meaning of existing `ReturnEntity` records. Returns stay linked refunds against expenses and are excluded/included explicitly in Dime-equivalent aggregate queries.

### Local service layer

Implement a new local-only `DimeDataController` façade backed by the existing `CoreDataModel.context`. It will provide Dime-shaped query and mutation operations (log totals, graph data, insight aggregates, category and budget lookup, recurrence processing, templates, and widgets) without importing Dime’s `NSPersistentCloudKitContainer`, `DataController.shared`, KVS, or CloudKit notifications.

Recurring processing runs locally at foreground/launch and after appropriate edits, transactionally and idempotently. It must never rely on remote changes. Each mutation saves through Squirrel’s existing context and reloads Squirrel widget timelines through its existing App Group flow.

## Ordered implementation tasks and acceptance criteria

1. **Legal, source baseline, and build baseline.** Record GPL decision, package licenses, current build status, store URL/model version, app-group/widget checks, and fixture backups.
   **Verify:** clean branch; no main changes; current unsigned IPA still includes app and widget extension; a copied local store opens without migration.

2. **Additive data-model migration and local façade.** Add the model version/entities/optional fields and `DimeDataController` query contracts with unit tests over pre-existing expense/category/return fixtures.
   **Verify:** lightweight migration retains every pre-existing entity UUID, amount, currency, category and return; no existing record is modified; all new transaction defaults are EUR and expense/non-recurring.

3. **Original Dime visual foundation.** Copy Dime color/font/shape/toolbar/toast utilities and required assets into namespaced multi-file Squirrel folders; add reviewed packages.
   **Verify:** project compiles at iOS 15; no icon/App Group/entitlement/bundle ID changes; Arabic and RTL snapshot/manual checks pass for shared controls.

4. **Original Dime transaction editor and categories.** Copy the Dime number pad, category picker, suggestions, transaction editor, category views, and adapters; implement local expense and income actions, edit, delete/undo, and EUR formatting.
   **Verify:** new expense and income save locally; legacy expenses/returns are unchanged; category create/edit/order/kind works; no currency chooser or rate request is exposed.

5. **Original Dime Home/Log first.** Copy `HomeView`, `CustomTabBar`, `LogView`, `LineGraph`, and photo export source; connect the Dime shell to the editor and local query façade.
   **Verify:** empty, populated, search, category/date/week/month/type, grouped-day, edit, delete/undo, graph, and RTL layouts match Dime behavior; foreground recurrence processing is local; widget data still refreshes.

6. **Templates and local recurrence.** Copy `TemplateTransactionView` and activate recurrence/template APIs.
   **Verify:** daily/weekly/monthly rules generate exactly once per due period after relaunch; templates create correct EUR entries; no CloudKit/KVS/network invocation occurs.

7. **Original Dime budgets.** Copy Dime budget source, shapes, and components; use additive local budget entities and aggregate queries.
   **Verify:** per-category and overall limits calculate from local expense/income/return rules as specified; edit/delete does not damage categories or transactions; migration fixtures remain intact.

8. **Original Dime insights.** Copy `InsightsView`, summary component, chart models, and local aggregates.
   **Verify:** all timeframe/category/type values equal independently calculated fixture totals; chart drag/animation works; Arabic/RTL chart labels and accessibility labels are correct.

9. **Original settings and local integrations.** Copy eligible settings, local notifications, backup/import guards, and app intents; explicitly omit `SettingsCloudView` and currency selection.
   **Verify:** settings persist locally/App Group as appropriate; EUR remains immutable for new transactions; export/import protects data; no iCloud, CloudKit, KVS, rate, or Alamofire path exists.

10. **Widget and release validation.** Adapt existing Squirrel widgets and shortcuts to the extended local schema; run full migration, UI, RTL, accessibility, and GitHub unsigned-IPA checks.
    **Verify:** IPA embeds both `Squirrel.app` and `SquirrelWidgetExtension.appex`; existing widgets continue to load; on-device testing covers onboarding, local-store upgrade, transaction input, recurrence, notification permission, widgets, Arabic/RTL, and backup restore.

## RTL and localization requirements for every stage

- Add Arabic entries to `financecontrol/Localizable.xcstrings`; do not retain Dime English literals as production UI.
- Replace physical left/right assumptions with semantic leading/trailing and use `layoutDirection` where Dime code uses fixed trailing deletion, fixed popover anchors, or directional icon names.
- Use locale-aware Arabic date/number presentation while keeping EUR currency formatting for newly created transactions.
- Test standard and large Dynamic Type sizes, VoiceOver labels, and both RTL/LTR layout before replacing each existing Squirrel route.

## Recommended first original Dime source set

After the legal and data-model gates, migrate this source set first: `Views/HomeView.swift`, `Views/CustomTabBar.swift`, `Views/LogView.swift`, `Views/LineGraph.swift`, `Models/FilterType.swift`, `Models/Line.swift`, `Components/Buttons/StepperButtons.swift`, `Utilities/Color.swift`, `Utilities/FontExtension.swift`, `Utilities/DynamicType.swift`, `Utilities/ViewExtension.swift`, `Utilities/AlertToast.swift`, and the necessary tab/log assets. Connect the Dime add action to an adapted Dime `TransactionView` only after Task 4’s additive income/category schema is proven safe.

This gives an authentic original Dime Home first while keeping Squirrel’s persistent data and local-only guarantees intact.
