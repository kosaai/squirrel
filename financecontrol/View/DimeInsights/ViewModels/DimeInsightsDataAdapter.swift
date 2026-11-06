import Foundation

@MainActor
final class DimeInsightsDataAdapter: ObservableObject {
    enum Period: CaseIterable, Identifiable, Hashable {
        case week, month, year

        var id: Self { self }

        var component: Calendar.Component {
            self == .week ? .weekOfYear : self == .month ? .month : .year
        }
    }

    struct CategoryTotal: Identifiable {
        let category: CategoryEntity?
        let amount: Double
        var id: String { category?.objectID.uriRepresentation().absoluteString ?? "uncategorized" }
        var percentage: Double = 0
    }

    struct Summary {
        let expenses: Double
        let income: Double
        var net: Double { income - expenses }
    }

    func range(for period: Period, now: Date = .now, calendar: Calendar = .autoupdatingCurrent) -> DateInterval {
        let start = calendar.dateInterval(of: period.component, for: now)?.start ?? now
        let end = calendar.date(byAdding: period.component, value: 1, to: start) ?? now
        return DateInterval(start: start, end: end)
    }

    func summary(spendings: [SpendingEntity], incomes: [IncomeEntity], period: Period, now: Date = .now) -> Summary {
        let range = range(for: period, now: now)
        let expenses = spendings
            .filter { $0.wrappedDate <= now && range.contains($0.wrappedDate) }
            .reduce(0) { $0 + $1.amountWithReturns }
        let income = incomes
            .filter { $0.wrappedDate <= now && range.contains($0.wrappedDate) }
            .reduce(0) { $0 + $1.amount }
        return Summary(expenses: expenses, income: income)
    }

    func categories(spendings: [SpendingEntity], period: Period, now: Date = .now) -> [CategoryTotal] {
        let range = range(for: period, now: now)
        let groups = Dictionary(grouping: spendings.filter { $0.wrappedDate <= now && range.contains($0.wrappedDate) }) { $0.category }
        let total = groups.values.flatMap { $0 }.reduce(0) { $0 + $1.amountWithReturns }
        return groups.map { category, values in
            let amount = values.reduce(0) { $0 + $1.amountWithReturns }
            return CategoryTotal(category: category, amount: amount, percentage: total > 0 ? amount / total : 0)
        }
        .sorted { $0.amount > $1.amount }
    }
}
