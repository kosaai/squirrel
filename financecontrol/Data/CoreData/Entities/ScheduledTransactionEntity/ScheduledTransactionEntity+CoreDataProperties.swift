import CoreData
import Foundation

extension ScheduledTransactionEntity {
    @nonobjc class func fetchRequest() -> NSFetchRequest<ScheduledTransactionEntity> { NSFetchRequest(entityName: "ScheduledTransactionEntity") }
    @NSManaged var amount: Double
    @NSManaged var comment: String?
    @NSManaged var createdAt: Date?
    @NSManaged var currency: String?
    @NSManaged var frequency: Int16
    @NSManaged var id: UUID?
    @NSManaged var interval: Int16
    @NSManaged var isActive: Bool
    @NSManaged var isIncome: Bool
    @NSManaged var nextDueDate: Date?
    @NSManaged var place: String?
    @NSManaged var startDate: Date?
    @NSManaged var category: CategoryEntity?
    @NSManaged var occurrences: NSSet?
}

extension ScheduledOccurrenceEntity {
    @nonobjc class func fetchRequest() -> NSFetchRequest<ScheduledOccurrenceEntity> { NSFetchRequest(entityName: "ScheduledOccurrenceEntity") }
    @NSManaged var createdAt: Date?
    @NSManaged var id: UUID?
    @NSManaged var scheduleID: UUID?
    @NSManaged var scheduledDate: Date?
    @NSManaged var income: IncomeEntity?
    @NSManaged var spending: SpendingEntity?
    @NSManaged var schedule: ScheduledTransactionEntity?
}

extension ScheduledTransactionEntity: Identifiable {
    var wrappedID: UUID { id ?? UUID() }
    var wrappedNextDueDate: Date { nextDueDate ?? startDate ?? .now }
}

enum DimeRecurrenceFrequency: Int16, CaseIterable, Identifiable, Hashable {
    case none, daily, weekly, monthly
    var id: Int16 { rawValue }
}

struct ScheduledTransactionLocal {
    let amount: Double
    let comment: String
    let categoryID: UUID
    let date: Date
    let isIncome: Bool
    let frequency: DimeRecurrenceFrequency
    let interval: Int
}
