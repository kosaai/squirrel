//
//  IncomesModel.swift
//  Squirrel
//
//  Local CRUD APIs for Dime-compatible EUR income transactions.
//

import CoreData

extension CoreDataModel {
    func fetchIncomes(
        from startDate: Date? = nil,
        through endDate: Date? = nil,
        categoryID: UUID? = nil,
        in context: NSManagedObjectContext? = nil
    ) -> [IncomeEntity] {
        let context = context ?? self.context
        return context.performAndWait {
            let request = IncomeEntity.fetchRequest()
            var predicates = [NSPredicate]()
            if let startDate { predicates.append(NSPredicate(format: "date >= %@", startDate as NSDate)) }
            if let endDate { predicates.append(NSPredicate(format: "date <= %@", endDate as NSDate)) }
            if let categoryID { predicates.append(NSPredicate(format: "category.id == %@", categoryID as CVarArg)) }
            request.predicate = predicates.isEmpty ? nil : NSCompoundPredicate(andPredicateWithSubpredicates: predicates)
            request.sortDescriptors = [NSSortDescriptor(key: "date", ascending: false)]
            return (try? context.fetch(request)) ?? []
        }
    }

    func addIncome(_ income: IncomeEntityLocal, timeZoneIdentifier: String = TimeZone.autoupdatingCurrent.identifier) {
        context.perform { [weak self] in
            guard let self,
                  income.amount > 0,
                  let category = self.findCategory(income.categoryID, in: self.context),
                  let description = NSEntityDescription.entity(forEntityName: "IncomeEntity", in: self.context)
            else { return }

            let entity = IncomeEntity(entity: description, insertInto: self.context)
            entity.id = UUID()
            entity.amount = income.amount
            entity.currency = "EUR"
            entity.comment = income.comment
            entity.date = income.date
            entity.place = income.place
            entity.timeZoneIdentifier = timeZoneIdentifier
            entity.category = category
            self.manager.save()
        }
    }

    func editIncome(_ income: IncomeEntity, with replacement: IncomeEntityLocal, timeZoneIdentifier: String = TimeZone.autoupdatingCurrent.identifier) {
        context.perform { [weak self] in
            guard let self,
                  replacement.amount > 0,
                  let category = self.findCategory(replacement.categoryID, in: self.context)
            else { return }

            income.amount = replacement.amount
            income.currency = "EUR"
            income.comment = replacement.comment
            income.date = replacement.date
            income.place = replacement.place
            income.timeZoneIdentifier = timeZoneIdentifier
            income.category = category
            self.manager.save()
        }
    }

    func deleteIncome(_ income: IncomeEntity) {
        context.perform { [weak self] in
            guard let self else { return }
            self.context.delete(income)
            self.manager.save()
        }
    }
}
