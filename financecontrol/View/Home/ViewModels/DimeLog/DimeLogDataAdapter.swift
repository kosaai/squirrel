//
//  DimeLogDataAdapter.swift
//  Squirrel
//
//  Local typed transaction adapter for the migrated Dime Log interface.
//

import Foundation
import CoreData
import Combine

@MainActor
final class DimeLogDataAdapter: ObservableObject {
    typealias Record = DimeTransactionDataAdapter.Record
    typealias Kind = DimeTransactionDataAdapter.Kind

    struct Day: Identifiable {
        let id: Date
        let transactions: [Record]
        /// Net amount: income minus expenses (which retain their return adjustment).
        let total: Double
    }

    struct Totals {
        let expenses: Double
        let income: Double
        var net: Double { income - expenses }
    }

    enum Timeframe: Int, CaseIterable {
        case today = 1, week, month, year, all
    }

    func allTransactions(from coreDataModel: CoreDataModel, incomes: [IncomeEntity]) -> [Record] {
        let expenses = coreDataModel.savedSpendings.map(Record.expense)
        let incomeRecords = incomes.map(Record.income)
        return (expenses + incomeRecords).sorted { $0.date > $1.date }
    }

    func filteredTransactions(
        from coreDataModel: CoreDataModel,
        query: String = "",
        category: CategoryEntity? = nil,
        dateRange: DateInterval? = nil,
        kind: Kind? = nil,
        incomes: [IncomeEntity]
    ) -> [Record] {
        allTransactions(from: coreDataModel, incomes: incomes).filter { transaction in
            guard transaction.date <= .now else { return false }
            if let category, transaction.category?.id != category.id { return false }
            if let dateRange, !dateRange.contains(transaction.date) { return false }
            if let kind, transaction.kind != kind { return false }

            guard !query.isEmpty else { return true }
            let needle = query.folding(options: [.caseInsensitive, .diacriticInsensitive], locale: .current)
            return transaction.searchTerms
                .contains { $0.folding(options: [.caseInsensitive, .diacriticInsensitive], locale: .current).contains(needle) }
        }
    }

    func groupedDays(_ transactions: [Record]) -> [Day] {
        let calendar = Calendar.autoupdatingCurrent
        let groups = Dictionary(grouping: transactions) { calendar.startOfDay(for: $0.date) }
        return groups.map { date, values in
            let sorted = values.sorted { $0.date > $1.date }
            return Day(id: date, transactions: sorted, total: signedTotal(of: sorted))
        }
        .sorted { $0.id > $1.id }
    }

    func totals(from transactions: [Record], timeframe: Timeframe) -> Totals {
        let range = dateRange(for: timeframe)
        let values = transactions.filter { range.contains($0.date) }
        return Totals(
            expenses: values.filter { $0.kind == .expense }.reduce(0) { $0 + $1.amount },
            income: values.filter { $0.kind == .income }.reduce(0) { $0 + $1.amount }
        )
    }

    func signedTotal(of transactions: [Record]) -> Double {
        transactions.reduce(0) { $0 + ($1.kind == .income ? $1.amount : -$1.amount) }
    }

    func dateRange(for timeframe: Timeframe, date: Date = .now) -> DateInterval {
        let calendar = Calendar.autoupdatingCurrent
        let end = calendar.date(byAdding: .second, value: 1, to: date) ?? date
        switch timeframe {
        case .today: return DateInterval(start: calendar.startOfDay(for: date), end: end)
        case .week: return DateInterval(start: calendar.dateInterval(of: .weekOfYear, for: date)?.start ?? date, end: end)
        case .month: return DateInterval(start: calendar.dateInterval(of: .month, for: date)?.start ?? date, end: end)
        case .year: return DateInterval(start: calendar.dateInterval(of: .year, for: date)?.start ?? date, end: end)
        case .all: return DateInterval(start: .distantPast, end: .distantFuture)
        }
    }

    func delete(_ transaction: Record, with coreDataModel: CoreDataModel) {
        switch transaction {
        case .expense(let spending): coreDataModel.deleteSpending(spending)
        case .income(let income): coreDataModel.deleteIncome(income)
        }
    }
}
