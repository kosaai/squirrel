import CoreData
import Foundation
@objc(DimeBudgetEntity) public class DimeBudgetEntity: NSManagedObject {}
extension DimeBudgetEntity { @nonobjc class func fetchRequest() -> NSFetchRequest<DimeBudgetEntity> { NSFetchRequest(entityName:"DimeBudgetEntity") }; @NSManaged var amount: Double; @NSManaged var createdAt: Date?; @NSManaged var id: UUID?; @NSManaged var modifiedAt: Date?; @NSManaged var period: Int16; @NSManaged var startDate: Date?; @NSManaged var category: CategoryEntity? }
extension DimeBudgetEntity: Identifiable { var wrappedStartDate: Date { startDate ?? .now } }
enum DimeBudgetPeriod: Int16, CaseIterable, Identifiable, Hashable { case week = 1, month, year; var id: Int16 { rawValue }; var component: Calendar.Component { self == .week ? .weekOfYear : self == .month ? .month : .year } }
struct DimeBudgetLocal { let amount: Double; let categoryID: UUID?; let period: DimeBudgetPeriod; let startDate: Date }
