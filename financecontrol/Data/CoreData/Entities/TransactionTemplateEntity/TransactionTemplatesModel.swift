import CoreData
import Foundation

extension CoreDataModel {
    func fetchTransactionTemplates(in context: NSManagedObjectContext? = nil) -> [TransactionTemplateEntity] {
        let managedContext = context ?? self.context
        return managedContext.performAndWait {
            let request = TransactionTemplateEntity.fetchRequest()
            request.sortDescriptors = [
                NSSortDescriptor(key: "order", ascending: true),
                NSSortDescriptor(key: "createdAt", ascending: true)
            ]
            return (try? managedContext.fetch(request)) ?? []
        }
    }

    func addTransactionTemplate(_ value: TransactionTemplateLocal) {
        context.performAndWait {
            guard value.amount > 0,
                  !value.name.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty,
                  let entity = NSEntityDescription.entity(forEntityName: "TransactionTemplateEntity", in: context)
            else { return }
            let template = TransactionTemplateEntity(entity: entity, insertInto: context)
            template.id = UUID()
            template.name = value.name.trimmingCharacters(in: .whitespacesAndNewlines)
            template.amount = value.amount
            template.isIncome = value.isIncome
            template.note = value.note
            template.order = value.order
            template.createdAt = .now
            template.modifiedAt = .now
            if let id = value.categoryID { template.category = findCategory(id, in: context) }
            manager.save()
        }
    }

    func editTransactionTemplate(_ template: TransactionTemplateEntity, with value: TransactionTemplateLocal) {
        context.performAndWait {
            guard value.amount > 0,
                  !value.name.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
            else { return }
            template.name = value.name.trimmingCharacters(in: .whitespacesAndNewlines)
            template.amount = value.amount
            template.isIncome = value.isIncome
            template.note = value.note
            template.order = value.order
            template.modifiedAt = .now
            template.category = value.categoryID.flatMap { findCategory($0, in: context) }
            manager.save()
        }
    }

    func deleteTransactionTemplate(_ template: TransactionTemplateEntity) {
        context.performAndWait {
            context.delete(template)
            manager.save()
        }
    }

    func reorderTransactionTemplates(_ templates: [TransactionTemplateEntity]) {
        context.performAndWait {
            for (index, template) in templates.enumerated() {
                template.order = Int32(index)
                template.modifiedAt = .now
            }
            manager.save()
        }
    }
}
