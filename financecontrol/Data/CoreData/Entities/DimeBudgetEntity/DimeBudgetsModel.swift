import CoreData
import Foundation
extension CoreDataModel {
 func fetchDimeBudgets() -> [DimeBudgetEntity] { context.performAndWait { let r=DimeBudgetEntity.fetchRequest(); r.sortDescriptors=[NSSortDescriptor(key:"createdAt",ascending:true)]; return (try? context.fetch(r)) ?? [] } }
 func addDimeBudget(_ value:DimeBudgetLocal) { context.performAndWait { guard value.amount > 0, let d=NSEntityDescription.entity(forEntityName:"DimeBudgetEntity",in:context) else{return}; let b=DimeBudgetEntity(entity:d,insertInto:context); b.id=UUID();b.amount=value.amount;b.period=value.period.rawValue;b.startDate=value.startDate;b.createdAt=.now;b.modifiedAt=.now;b.category=value.categoryID.flatMap{findCategory($0,in:context)};manager.save() } }
 func editDimeBudget(_ budget:DimeBudgetEntity, with value:DimeBudgetLocal) { context.performAndWait { guard value.amount>0 else{return}; budget.amount=value.amount;budget.period=value.period.rawValue;budget.startDate=value.startDate;budget.category=value.categoryID.flatMap{findCategory($0,in:context)};budget.modifiedAt=.now;manager.save() } }
 func deleteDimeBudget(_ budget:DimeBudgetEntity) { context.performAndWait { context.delete(budget);manager.save() } }
}
