import CoreData
import Foundation

extension CoreDataModel {
    func fetchScheduledTransactions(in context: NSManagedObjectContext? = nil) -> [ScheduledTransactionEntity] {
        let context = context ?? self.context
        return context.performAndWait {
            let request = ScheduledTransactionEntity.fetchRequest()
            request.sortDescriptors = [NSSortDescriptor(key: "nextDueDate", ascending: true)]
            return (try? context.fetch(request)) ?? []
        }
    }

    func addScheduledTransaction(_ local: ScheduledTransactionLocal) {
        context.performAndWait {
            guard local.amount > 0, local.interval > 0,
                  let entity = NSEntityDescription.entity(forEntityName: "ScheduledTransactionEntity", in: context)
            else { return }
            let category = local.categoryID.flatMap { findCategory($0, in: context) }
            guard local.categoryID == nil || category != nil else { return }
            guard !local.isIncome || category != nil else { return }
            let schedule = ScheduledTransactionEntity(entity: entity, insertInto: context)
            schedule.id = UUID()
            schedule.amount = local.amount
            schedule.comment = local.comment
            schedule.currency = "EUR"
            schedule.createdAt = .now
            schedule.startDate = local.date
            schedule.nextDueDate = local.date
            schedule.isIncome = local.isIncome
            schedule.frequency = local.frequency.rawValue
            schedule.interval = Int16(local.interval)
            schedule.isActive = true
            schedule.category = category
            manager.save()
        }
    }

    func editScheduledTransaction(_ schedule: ScheduledTransactionEntity, with local: ScheduledTransactionLocal) {
        context.performAndWait {
            guard local.amount > 0, local.interval > 0 else { return }
            let category = local.categoryID.flatMap { findCategory($0, in: context) }
            guard local.categoryID == nil || category != nil else { return }
            guard !local.isIncome || category != nil else { return }
            schedule.amount = local.amount
            schedule.comment = local.comment
            schedule.currency = "EUR"
            schedule.startDate = local.date
            schedule.nextDueDate = local.date
            schedule.isIncome = local.isIncome
            schedule.frequency = local.frequency.rawValue
            schedule.interval = Int16(local.interval)
            schedule.isActive = true
            schedule.category = category
            manager.save()
        }
    }

    func cancelScheduledTransaction(_ schedule: ScheduledTransactionEntity) {
        context.performAndWait {
            schedule.isActive = false
            manager.save()
        }
    }

    /// Generates each due occurrence once. The occurrence ledger is checked before every insert.
    func generateDueScheduledTransactions(asOf date: Date = .now, calendar: Calendar = .autoupdatingCurrent) {
        context.performAndWait {
            let request = ScheduledTransactionEntity.fetchRequest()
            request.predicate = NSPredicate(format: "isActive == YES AND nextDueDate <= %@", date as NSDate)
            let schedules = (try? context.fetch(request)) ?? []
            for schedule in schedules {
                generateDueOccurrences(for: schedule, asOf: date, calendar: calendar)
            }
            manager.save()
        }
    }

    private func generateDueOccurrences(for schedule: ScheduledTransactionEntity, asOf date: Date, calendar: Calendar) {
        guard let scheduleID = schedule.id else { return }
        guard !schedule.isIncome || schedule.category != nil else { return }
        let category = schedule.category
        var due = schedule.wrappedNextDueDate
        while schedule.isActive && due <= date {
            let occurrenceRequest = ScheduledOccurrenceEntity.fetchRequest()
            occurrenceRequest.fetchLimit = 1
            occurrenceRequest.predicate = NSPredicate(format: "scheduleID == %@ AND scheduledDate == %@", scheduleID as CVarArg, due as NSDate)
            let alreadyGenerated = ((try? context.fetch(occurrenceRequest)) ?? []).first != nil
            if !alreadyGenerated, let occurrenceDescription = NSEntityDescription.entity(forEntityName: "ScheduledOccurrenceEntity", in: context) {
                let occurrence = ScheduledOccurrenceEntity(entity: occurrenceDescription, insertInto: context)
                occurrence.id = UUID()
                occurrence.scheduleID = scheduleID
                occurrence.scheduledDate = due
                occurrence.createdAt = .now
                occurrence.schedule = schedule
                if schedule.isIncome {
                    guard let incomeDescription = NSEntityDescription.entity(forEntityName: "IncomeEntity", in: context) else { continue }
                    let income = IncomeEntity(entity: incomeDescription, insertInto: context)
                    guard let category else { continue }
                    income.id = UUID(); income.amount = schedule.amount; income.currency = "EUR"; income.comment = schedule.comment; income.date = due; income.place = schedule.place; income.category = category
                    occurrence.income = income
                } else {
                    guard let spendingDescription = NSEntityDescription.entity(forEntityName: "SpendingEntity", in: context) else { continue }
                    let spending = SpendingEntity(entity: spendingDescription, insertInto: context)
                    spending.id = UUID(); spending.amount = schedule.amount; spending.amountUSD = schedule.amount; spending.currency = "EUR"; spending.comment = schedule.comment; spending.date = due; spending.place = schedule.place; spending.category = category
                    occurrence.spending = spending
                }
            }
            guard let next = nextDueDate(after: due, frequency: DimeRecurrenceFrequency(rawValue: schedule.frequency) ?? .none, interval: Int(schedule.interval), calendar: calendar) else {
                schedule.isActive = false
                break
            }
            schedule.nextDueDate = next
            due = next
        }
    }

    private func nextDueDate(after date: Date, frequency: DimeRecurrenceFrequency, interval: Int, calendar: Calendar) -> Date? {
        switch frequency {
        case .none: return nil
        case .daily: return calendar.date(byAdding: .day, value: interval, to: date)
        case .weekly: return calendar.date(byAdding: .weekOfYear, value: interval, to: date)
        case .monthly: return calendar.date(byAdding: .month, value: interval, to: date)
        }
    }
}
