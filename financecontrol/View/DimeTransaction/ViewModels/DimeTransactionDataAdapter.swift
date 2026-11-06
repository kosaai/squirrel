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
    func save(
        existing: SpendingEntity?,
        amount: Double,
        note: String,
        category: CategoryEntity?,
        date: Date,
        coreDataModel: CoreDataModel
    ) {
        guard amount > 0, let categoryID = category?.id else { return }
        let spending = SpendingEntityLocal(
            amount: amount,
            amountUSD: amount,
            currency: "EUR",
            date: date,
            place: "",
            categoryId: categoryID,
            comment: note
        )

        if let existing {
            coreDataModel.editSpending(spending: existing, newSpending: spending, exchangeRate: 1)
        } else {
            coreDataModel.addSpending(
                spending: spending,
                timeZoneIdentifier: TimeZone.autoupdatingCurrent.identifier,
                addToFetchQueue: false
            )
        }
    }

    func suggestions(note: String, from spendings: [SpendingEntity]) -> [SpendingEntity] {
        let normalized = note.folding(options: [.caseInsensitive, .diacriticInsensitive], locale: .current)
        return spendings.filter {
            guard !normalized.isEmpty else { return true }
            return ($0.comment ?? "").folding(options: [.caseInsensitive, .diacriticInsensitive], locale: .current).contains(normalized)
        }
        .prefix(5)
        .map { $0 }
    }
}
