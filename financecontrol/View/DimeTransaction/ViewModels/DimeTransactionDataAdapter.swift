//
//  DimeTransactionDataAdapter.swift
//  Squirrel
//
//  Local adapter for the Dime transaction editor visual source.
//

import Foundation
import Combine

@MainActor
final class DimeTransactionDataAdapter: ObservableObject {
    enum Kind: String, CaseIterable, Identifiable {
        case expense, income
        var id: String { rawValue }
    }

    enum Record: Identifiable {
        case expense(SpendingEntity)
        case income(IncomeEntity)

        var id: String {
            switch self {
            case .expense(let spending): return "expense-\(spending.objectID.uriRepresentation().absoluteString)"
            case .income(let income): return "income-\(income.objectID.uriRepresentation().absoluteString)"
            }
        }

        var kind: Kind {
            switch self {
            case .expense: return .expense
            case .income: return .income
            }
        }

        var amount: Double {
            switch self {
            case .expense(let spending): return spending.amountWithReturns
            case .income(let income): return income.amount
            }
        }

        var note: String {
            switch self {
            case .expense(let spending): return spending.comment ?? ""
            case .income(let income): return income.comment ?? ""
            }
        }

        var category: CategoryEntity? {
            switch self {
            case .expense(let spending): return spending.category
            case .income(let income): return income.category
            }
        }

        var date: Date {
            switch self {
            case .expense(let spending): return spending.wrappedDate
            case .income(let income): return income.wrappedDate
            }
        }

        var searchTerms: [String] {
            switch self {
            case .expense(let spending): return [note, spending.place ?? "", category?.name ?? "", String(amount)]
            case .income: return [note, category?.name ?? "", String(amount)]
            }
        }
    }

    func save(
        existing: Record?,
        kind: Kind,
        amount: Double,
        note: String,
        category: CategoryEntity?,
        date: Date,
        coreDataModel: CoreDataModel
    ) {
        guard amount > 0, let categoryID = category?.id else { return }
        switch (kind, existing) {
        case (.expense, .some(.expense(let existing))):
            coreDataModel.editSpending(spending: existing, newSpending: spending(from: amount, note: note, categoryID: categoryID, date: date), exchangeRate: 1)
        case (.expense, _):
            coreDataModel.addSpending(spending: spending(from: amount, note: note, categoryID: categoryID, date: date), timeZoneIdentifier: TimeZone.autoupdatingCurrent.identifier, addToFetchQueue: false)
        case (.income, .some(.income(let existing))):
            coreDataModel.editIncome(existing, with: income(from: amount, note: note, categoryID: categoryID, date: date))
        case (.income, _):
            coreDataModel.addIncome(income(from: amount, note: note, categoryID: categoryID, date: date))
        }
    }

    func suggestions(note: String, kind: Kind, from coreDataModel: CoreDataModel) -> [Record] {
        let normalized = note.folding(options: [.caseInsensitive, .diacriticInsensitive], locale: .current)
        let records: [Record] = kind == .expense
            ? coreDataModel.savedSpendings.map(Record.expense)
            : coreDataModel.fetchIncomes().map(Record.income)
        return records.filter {
            guard !normalized.isEmpty else { return true }
            return $0.note.folding(options: [.caseInsensitive, .diacriticInsensitive], locale: .current).contains(normalized)
        }
        .prefix(5)
        .map { $0 }
    }

    private func spending(from amount: Double, note: String, categoryID: UUID, date: Date) -> SpendingEntityLocal {
        SpendingEntityLocal(amount: amount, amountUSD: amount, currency: "EUR", date: date, place: "", categoryId: categoryID, comment: note)
    }

    private func income(from amount: Double, note: String, categoryID: UUID, date: Date) -> IncomeEntityLocal {
        IncomeEntityLocal(amount: amount, comment: note, categoryID: categoryID, date: date)
    }
}
