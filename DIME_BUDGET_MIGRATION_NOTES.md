# Dime Budget migration

Source mapping: Dime `Views/BudgetView.swift` informs the card/summary presentation; `Views/NewBudgetView.swift` informs the rounded edit flow, progress visuals, period selection, and category/overall budget choices; `Models/BudgetTimeFrame.swift` maps to `DimeBudgetPeriod`.

`BudgetsModel.xcdatamodel` adds only `DimeBudgetEntity` (amount, UUID, period, start/creation/modification dates, optional category). No transaction entities or previous model versions are changed.

Compatibility adaptation: completed `SpendingEntity.amountWithReturns` values are used for actual spend. Income and future schedules are separate entities and excluded. Generated recurring occurrences are ordinary completed expenses and are included once, as they have one SpendingEntity each.
