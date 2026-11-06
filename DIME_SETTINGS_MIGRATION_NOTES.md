# Dime Settings migration

Source mapping: Dime `Views/Settings/SettingsView.swift` supplies the title/header, grouped sections, rounded setting rows, typography, colors, and navigation hierarchy. Dime subviews inspected include appearance, app icon, cloud, currency, erase, haptics, notifications, number entry, week start, and upcoming transactions.

Compatible Squirrel functionality remains available through `DimeSquirrelSettingsAdapter`, which presents its existing Settings destinations for category management, appearance, privacy, data export/backup, and application information. The adapter avoids copying or resetting preference values.

Dime Cloud Sync and currency-selection rows are omitted because Squirrel's migration target is local-only and EUR-only; misleading unsupported controls are not shown. The active Squirrel Settings screen is unchanged.
