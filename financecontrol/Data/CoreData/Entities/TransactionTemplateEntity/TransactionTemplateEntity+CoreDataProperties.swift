import CoreData
import Foundation
extension TransactionTemplateEntity {
 @nonobjc class func fetchRequest() -> NSFetchRequest<TransactionTemplateEntity> { NSFetchRequest(entityName: "TransactionTemplateEntity") }
 @NSManaged var amount: Double; @NSManaged var createdAt: Date?; @NSManaged var id: UUID?; @NSManaged var isIncome: Bool; @NSManaged var modifiedAt: Date?; @NSManaged var name: String?; @NSManaged var note: String?; @NSManaged var order: Int32; @NSManaged var category: CategoryEntity?
}
extension TransactionTemplateEntity: Identifiable { var wrappedName: String { name ?? "" } }
struct TransactionTemplateLocal { let name: String; let amount: Double; let isIncome: Bool; let categoryID: UUID?; let note: String; let order: Int32 }
