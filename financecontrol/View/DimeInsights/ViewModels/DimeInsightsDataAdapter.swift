import Foundation
@MainActor final class DimeInsightsDataAdapter: ObservableObject {
 enum Period: CaseIterable, Identifiable { case week, month, year; var id: Self { self }; var component: Calendar.Component { self == .week ? .weekOfYear : self == .month ? .month : .year } }
 struct CategoryTotal: Identifiable { let category: CategoryEntity?; let amount: Double; var id: String { category?.objectID.uriRepresentation().absoluteString ?? "uncategorized" }; var percentage: Double = 0 }
 struct Summary { let expenses: Double; let income: Double; var net: Double { income-expenses } }
 func range(for period:Period, now:Date=.now, calendar:Calendar=.autoupdatingCurrent)->DateInterval { DateInterval(start:calendar.dateInterval(of:period.component,for:now)?.start ?? now,end:(calendar.date(byAdding:period.component,value:1,to:calendar.dateInterval(of:period.component,for:now)?.start ?? now) ?? now)) }
 func summary(spendings:[SpendingEntity], incomes:[IncomeEntity], period:Period, now:Date=.now)->Summary { let r=range(for:period,now:now); return .init(expenses:spendings.filter{$0.wrappedDate <= now && r.contains($0.wrappedDate)}.reduce(0){$0+$1.amountWithReturns},income:incomes.filter{$0.wrappedDate <= now && r.contains($0.wrappedDate)}.reduce(0){$0+$1.amount}) }
 func categories(spendings:[SpendingEntity], period:Period, now:Date=.now)->[CategoryTotal] { let r=range(for:period,now:now); let g=Dictionary(grouping:spendings.filter{$0.wrappedDate <= now && r.contains($0.wrappedDate)}){$0.category};let total=g.values.flatMap{$0}.reduce(0){$0+$1.amountWithReturns};return g.map{c,v in CategoryTotal(category:c,amount:v.reduce(0){$0+$1.amountWithReturns},percentage:total > 0 ? v.reduce(0){$0+$1.amountWithReturns}/total : 0)}.sorted{$0.amount>$1.amount} }
}
