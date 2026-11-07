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
    enum SaveError: Error {
        case invalidAmount
        case missingCategory
        case persistence(Error)

        var localizationKey: String {
            switch self {
            case .invalidAmount:
                return "Dime Transaction Invalid Amount"
            case .missingCategory:
                return "Dime Transaction Missing Category"
            case .persistence:
                return "Dime Transaction Save Error Message"
            }
        }
    }

    @Published private(set) var isSaving = false

    enum Kind: String, CaseIterable, Identifiable, Hashable {
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
        coreDataModel: CoreDataModel,
        completion: @escaping (Result<Void, SaveError>) -> Void
    ) {
        guard !isSaving else { return }
        guard amount > 0 else {
            completion(.failure(.invalidAmount))
            return
        }
        if kind == .income, category?.id == nil {
            completion(.failure(.missingCategory))
            return
        }
        let categoryID = category?.id

        isSaving = true
        let finish: (Result<Void, Error>) -> Void = { [weak self] result in
            Task { @MainActor in
                self?.isSaving = false
                completion(result.mapError { .persistence($0) })
            }
        }

        switch (kind, existing) {
        case (.expense, .some(.expense(let existing))):
            coreDataModel.editSpending(
                spending: existing,
                newSpending: spending(from: amount, note: note, categoryID: categoryID, date: date),
                exchangeRate: 1,
                completion: finish
            )
        case (.expense, _):
            coreDataModel.addSpending(
                spending: spending(from: amount, note: note, categoryID: categoryID, date: date),
                timeZoneIdentifier: TimeZone.autoupdatingCurrent.identifier,
                addToFetchQueue: false,
                completion: finish
            )
        case (.income, .some(.income(let existing))):
            guard let categoryID else {
                completion(.failure(.missingCategory))
                return
            }
            coreDataModel.editIncome(
                existing,
                with: income(from: amount, note: note, categoryID: categoryID, date: date),
                completion: finish
            )
        case (.income, _):
            guard let categoryID else {
                completion(.failure(.missingCategory))
                return
            }
            coreDataModel.addIncome(
                income(from: amount, note: note, categoryID: categoryID, date: date),
                completion: finish
            )
        }
    }

    func saveScheduled(
        amount: Double,
        note: String,
        category: CategoryEntity?,
        date: Date,
        kind: Kind,
        frequency: DimeRecurrenceFrequency,
        interval: Int,
        coreDataModel: CoreDataModel
    ) {
        guard amount > 0 else { return }
        guard kind == .expense || category?.id != nil else { return }
        coreDataModel.addScheduledTransaction(.init(amount: amount, comment: note, categoryID: categoryID, date: date, isIncome: kind == .income, frequency: frequency, interval: interval))
        coreDataModel.generateDueScheduledTransactions()
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

    private func spending(from amount: Double, note: String, categoryID: UUID?, date: Date) -> SpendingEntityLocal {
        SpendingEntityLocal(amount: amount, amountUSD: amount, currency: "EUR", date: date, place: "", categoryId: categoryID, comment: note)
    }

    private func income(from amount: Double, note: String, categoryID: UUID, date: Date) -> IncomeEntityLocal {
        IncomeEntityLocal(amount: amount, comment: note, categoryID: categoryID, date: date)
    }
}
