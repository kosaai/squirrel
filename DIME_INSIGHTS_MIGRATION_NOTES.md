# Dime Insights migration

Source mapping: `Views/InsightsView.swift` supplies the screen hierarchy, empty state, period menu, custom horizontal category chart, rounded typography, and color vocabulary. `Views/LineGraph.swift` and the chart helpers embedded in `InsightsView.swift` are the original custom graph approach; no third-party chart package is required. `Models/ChartTimeFrame.swift` maps to `DimeInsightsDataAdapter.Period`.

The local adapter uses completed Squirrel expenses (`amountWithReturns`) and income records. Pending schedules are not fetched; generated occurrences appear exactly once through their completed records.
