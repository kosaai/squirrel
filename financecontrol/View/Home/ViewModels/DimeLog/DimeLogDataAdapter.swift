//
//  DimeLogDataAdapter.swift
//  Squirrel
//
//  Adapted from Dime's LogView data contracts. This remains local-only.
//

import Foundation
import CoreData
import Combine

@MainActor
final class DimeLogDataAdapter: ObservableObject {
    struct Day: Identifiable {
        let id: Date
        let spendings: [SpendingEntity]
        let total: Double
    }

    enum Timeframe: Int, CaseIterable {
        case today = 1, week, month, year, all
    }

    func allSpendings(from coreDataModel: CoreDataModel) -> [SpendingEntity] {
        coreDataModel.savedSpendings.sorted { $0.wrappedDate > $1.wrappedDate }
    }

    func filteredSpendings(
        from coreDataModel: CoreDataModel,
        query: String = "",
        category: CategoryEntity? = nil,
        dateRange: DateInterval? = nil
    ) -> [SpendingEntity] {
        allSpendings(from: coreDataModel).filter { spending in
            guard spending.wrappedDate <= .now else { return false }
            if let category, spending.category?.id != category.id { return false }
            if let dateRange, !dateRange.contains(spending.wrappedDate) { return false }

            guard !query.isEmpty else { return true }
            let needle = query.folding(options: [.caseInsensitive, .diacriticInsensitive], locale: .current)
            return [spending.comment ?? "", spending.place ?? "", spending.category?.name ?? "", String(spending.amount)]
                .contains { $0.folding(options: [.caseInsensitive, .diacriticInsensitive], locale: .current).contains(needle) }
        }
    }

    func groupedDays(_ spendings: [SpendingEntity]) -> [Day] {
        let calendar = Calendar.autoupdatingCurrent
        let groups = Dictionary(grouping: spendings) { calendar.startOfDay(for: $0.wrappedDate) }
        return groups.map { date, values in
            Day(id: date, spendings: values.sorted { $0.wrappedDate > $1.wrappedDate }, total: values.reduce(0) { $0 - $1.amountWithReturns })
        }
        .sorted { $0.id > $1.id }
    }

    func total(from spendings: [SpendingEntity], timeframe: Timeframe) -> Double {
        let range = dateRange(for: timeframe)
        return spendings.filter { range.contains($0.wrappedDate) }.reduce(0) { $0 + $1.amountWithReturns }
    }

    func dateRange(for timeframe: Timeframe, date: Date = .now) -> DateInterval {
        let calendar = Calendar.autoupdatingCurrent
        let end = calendar.date(byAdding: .second, value: 1, to: date) ?? date
        switch timeframe {
        case .today:
            return DateInterval(start: calendar.startOfDay(for: date), end: end)
        case .week:
            return DateInterval(start: calendar.dateInterval(of: .weekOfYear, for: date)?.start ?? date, end: end)
        case .month:
            return DateInterval(start: calendar.dateInterval(of: .month, for: date)?.start ?? date, end: end)
        case .year:
            return DateInterval(start: calendar.dateInterval(of: .year, for: date)?.start ?? date, end: end)
        case .all:
            return DateInterval(start: .distantPast, end: .distantFuture)
        }
    }

    func delete(_ spending: SpendingEntity, with coreDataModel: CoreDataModel) {
        coreDataModel.deleteSpending(spending)
    }
}
