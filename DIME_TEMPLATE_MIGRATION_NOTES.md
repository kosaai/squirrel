# Dime template migration

Dime has a native saved-template feature in `Views/TemplateTransactionView.swift` and the `TemplateTransaction` Core Data entity. Its segmented income/expense treatment, category selection conventions, number entry, rounded typography, and recurrence-aware editor conventions inform this migration. `DimeTemplatesView.swift` is a Squirrel-specific persistence adapter using that visual language; it is not claimed to be a verbatim copy.

`TemplatesModel.xcdatamodel` is an additive current version. `TransactionTemplateEntity` stores a UUID, name, income flag, EUR amount, optional note, ordering, creation/modification dates, and an optional category relationship. It has no relation to completed records or schedules. A missing/deleted category remains an optional relationship and templates stay loadable.

Applying a template updates only the inactive Dime editor state. It does not write an income/expense, change the selected date, or create a recurrence.

## Task 10.1 fidelity correction

`DimeTemplateTransactionEditor.swift` is the source-driven migration of Dime's `TemplateTransactionView.swift`: the template editor's top income/expense capsule, close/delete controls, amount display, note/category controls, number pad, rounded typography, color tokens, and matched-geometry selection animation are retained. It adapts only category and template CRUD bindings to Squirrel's local APIs.

`DimeTemplatesView.swift` remains Squirrel-specific because original Dime selects templates through fixed template slots rather than a reusable saved-template management list with create, reorder, edit, and delete operations. Its sole role is that missing management capability; it presents the original-style editor for creation and editing.
