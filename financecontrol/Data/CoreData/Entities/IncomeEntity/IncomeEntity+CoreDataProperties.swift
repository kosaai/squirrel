//
//  IncomeEntity+CoreDataProperties.swift
//  Squirrel
//

import Foundation
import CoreData

extension IncomeEntity {
    @nonobjc public class func fetchRequest() -> NSFetchRequest<IncomeEntity> {
        NSFetchRequest<IncomeEntity>(entityName: "IncomeEntity")
    }

    @NSManaged public var amount: Double
    @NSManaged public var comment: String?
    @NSManaged public var currency: String?
    @NSManaged public var date: Date?
    @NSManaged public var id: UUID?
    @NSManaged public var place: String?
    @NSManaged public var timeZoneIdentifier: String?
    @NSManaged public var category: CategoryEntity?
}

extension IncomeEntity: Identifiable {
    var wrappedDate: Date { date ?? .now }
    var wrappedID: UUID { id ?? UUID() }
    var wrappedCurrency: String { currency ?? "EUR" }
}

struct IncomeEntityLocal {
    let amount: Double
    let comment: String
    let categoryID: UUID
    let date: Date
    let place: String

    init(amount: Double, comment: String = "", categoryID: UUID, date: Date = .now, place: String = "") {
        self.amount = amount
        self.comment = comment
        self.categoryID = categoryID
        self.date = date
        self.place = place
    }
}
