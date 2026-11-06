# Dime recurring and future transaction migration

Migrated Dime source behavior from `Data/DataController.swift` (`updateRecurringTransaction`, `updateRecurringTransactions`, and `newTransaction`) and `Views/TransactionView.swift` (`RecurringPickerView`, `CustomRecurringView`). The local adaptation retains Dime's daily, weekly, monthly, and custom 1–30 interval choices.

`ScheduledTransactionsModel.xcdatamodel` is an additive model version. It adds `ScheduledTransactionEntity` for both recurring and one-time future schedules and `ScheduledOccurrenceEntity` as a generated-occurrence ledger. Completed income and expense records stay in their existing entities; schedules are never counted as completed Log records before their due date.

The scheduler advances from the stored due date with Calendar day/week/month operations, generating missed dates in order. Before inserting it checks the schedule UUID plus due date in the ledger, then links that ledger entry to exactly one newly created local income or expense. Cancelling only marks a schedule inactive, retaining the completed occurrence history.

Runtime upgrade testing against a copy of a pre-schedule store remains required before activation.
