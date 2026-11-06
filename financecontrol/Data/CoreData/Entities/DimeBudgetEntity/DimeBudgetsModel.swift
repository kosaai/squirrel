import CoreData
import Foundation

extension CoreDataModel {
    func fetchDimeBudgets() -> [DimeBudgetEntity] {
        context.performAndWait {
            let request = DimeBudgetEntity.fetchRequest()
            request.sortDescriptors = [NSSortDescriptor(key: "createdAt", ascending: true)]
            return (try? context.fetch(request)) ?? []
        }
    }

    func addDimeBudget(_ value: DimeBudgetLocal) {
        context.performAndWait {
            guard value.amount > 0,
                  let entity = NSEntityDescription.entity(forEntityName: "DimeBudgetEntity", in: context)
            else { return }
            let budget = DimeBudgetEntity(entity: entity, insertInto: context)
            budget.id = UUID()
            budget.amount = value.amount
            budget.period = value.period.rawValue
            budget.startDate = value.startDate
            budget.createdAt = .now
            budget.modifiedAt = .now
            budget.category = value.categoryID.flatMap { findCategory($0, in: context) }
            manager.save()
        }
    }

    func editDimeBudget(_ budget: DimeBudgetEntity, with value: DimeBudgetLocal) {
        context.performAndWait {
            guard value.amount > 0 else { return }
            budget.amount = value.amount
            budget.period = value.period.rawValue
            budget.startDate = value.startDate
            budget.category = value.categoryID.flatMap { findCategory($0, in: context) }
            budget.modifiedAt = .now
            manager.save()
        }
    }

    func deleteDimeBudget(_ budget: DimeBudgetEntity) {
        context.performAndWait {
            context.delete(budget)
            manager.save()
        }
    }
}
