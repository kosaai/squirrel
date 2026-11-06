import Foundation
struct DimeBudgetSnapshot { let spent: Double; let limit: Double; var remaining: Double { limit-spent }; var fraction: Double { limit > 0 ? min(spent/limit, 1) : 0 } }
@MainActor final class DimeBudgetDataAdapter: ObservableObject {
 func snapshot(for budget:DimeBudgetEntity, spendings:[SpendingEntity], now:Date = .now, calendar:Calendar = .autoupdatingCurrent) -> DimeBudgetSnapshot {
  let period=DimeBudgetPeriod(rawValue:budget.period) ?? .month
  var start=budget.wrappedStartDate
  while let next=calendar.date(byAdding:period.component,value:1,to:start), next <= now { start=next }
  let end=calendar.date(byAdding:period.component,value:1,to:start) ?? now
  let spent=spendings.filter { $0.wrappedDate >= start && $0.wrappedDate < end && $0.wrappedDate <= now && (budget.category == nil || $0.category?.id == budget.category?.id) }.reduce(0) { $0 + $1.amountWithReturns }
  return .init(spent:spent,limit:budget.amount)
 }
}
