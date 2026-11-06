//
//  DimeLogView.swift
//  Squirrel
//
//  Directly adapted from app/dime/Views/LogView.swift (Dime).
//  Remote sync and Dime persistence calls are intentionally excluded.
//

import SwiftUI
import CoreData

struct DimeLogView: View {
    @EnvironmentObject private var coreDataModel: CoreDataModel
    @FetchRequest(sortDescriptors: [NSSortDescriptor(key: "date", ascending: false)]) private var incomes: FetchedResults<IncomeEntity>
    @StateObject private var adapter = DimeLogDataAdapter()
    @State private var searchMode = false
    @State private var searchQuery = ""
    @State private var showFilter = false
    @State private var filter = DimeLogFilter.all
    @State private var category: CategoryEntity?
    @State private var filterDate = Date.now
    @State private var filterWeek = Date.now
    @State private var filterMonth = Date.now
    @State private var timeframe: DimeLogDataAdapter.Timeframe = .month
    @State private var transactionKind: DimeLogDataAdapter.Kind = .expense
    @State private var selectedTransaction: DimeTransactionDataAdapter.Record?

    var topEdge: CGFloat = 0
    var bottomEdge: CGFloat = 0

    private var transactions: [DimeLogDataAdapter.Record] {
        adapter.filteredTransactions(
            from: coreDataModel,
            query: searchQuery,
            category: filter == .category ? category : nil,
            dateRange: activeDateRange,
            kind: filter == .type ? transactionKind : nil,
            incomes: Array(incomes)
        )
    }

    private var allTransactions: [DimeLogDataAdapter.Record] {
        adapter.allTransactions(from: coreDataModel, incomes: Array(incomes))
    }

    private var activeDateRange: DateInterval? {
        let calendar = Calendar.autoupdatingCurrent
        switch filter {
        case .day:
            return calendar.dateInterval(of: .day, for: filterDate)
        case .week:
            return calendar.dateInterval(of: .weekOfYear, for: filterWeek)
        case .month:
            return calendar.dateInterval(of: .month, for: filterMonth)
        default:
            return nil
        }
    }

    var body: some View {
        Group {
            if allTransactions.isEmpty {
                DimeLogEmptyState()
            } else {
                VStack(spacing: 0) {
                    DimeLogHeader(
                        searchMode: $searchMode,
                        showFilter: $showFilter,
                        filter: $filter,
                        category: $category,
                        date: $filterDate,
                        week: $filterWeek,
                        month: $filterMonth,
                        transactionKind: $transactionKind,
                        categories: coreDataModel.savedCategories
                    )
                    .padding(.horizontal, 25)
                    .padding(.top, topEdge + 10)

                    ScrollView(showsIndicators: false) {
                        if filter == .all {
                            DimeLogInsights(
                                totals: adapter.totals(from: allTransactions, timeframe: timeframe),
                                timeframe: $timeframe
                            )
                        }

                        DimeLogTransactionList(
                            days: adapter.groupedDays(transactions),
                            onEdit: { selectedTransaction = $0 },
                            onDelete: { adapter.delete($0, with: coreDataModel) },
                            bottomEdge: bottomEdge
                        )
                        .padding(.horizontal, 20)
                        .padding(.bottom, 70 + bottomEdge)
                    }
                }
            }
        }
        .background(Color.PrimaryBackground)
        .sheet(isPresented: $searchMode) {
            DimeLogSearchView(query: $searchQuery)
        }
        .sheet(item: $selectedTransaction) { transaction in
            DimeTransactionView(transactionToEdit: transaction)
                .environmentObject(coreDataModel)
        }
        .onAppear {
            coreDataModel.generateDueScheduledTransactions()
        }
    }
}

private struct DimeLogEmptyState: View {
    var body: some View {
        VStack(spacing: 5) {
            Image("dropbox")
                .resizable()
                .frame(width: 75, height: 75)
                .padding(.bottom, 20)
                .accessibility(hidden: true)
            Text("Dime Log Empty")
                .font(.system(.title2, design: .rounded).weight(.medium))
                .multilineTextAlignment(.center)
                .foregroundColor(Color.PrimaryText.opacity(0.8))
            Text("Dime Log Add First Entry")
                .font(.system(.body, design: .rounded).weight(.medium))
                .multilineTextAlignment(.center)
                .foregroundColor(Color.SubtitleText.opacity(0.7))
        }
        .padding(.horizontal, 30)
        .frame(height: 250, alignment: .top)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color.PrimaryBackground)
    }
}

private struct DimeLogInsights: View {
    let totals: DimeLogDataAdapter.Totals
    @Binding var timeframe: DimeLogDataAdapter.Timeframe
    @State private var showMenu = false
    @State private var showSummaryMenu = false
    @State private var summary: DimeLogSummary = .net

    var body: some View {
        VStack(spacing: 2) {
            HStack(spacing: 4) {
                Button { showSummaryMenu = true } label: {
                    Text(summary.title)
                        .font(.system(.body, design: .rounded).weight(.medium))
                        .foregroundColor(Color.PrimaryText.opacity(0.9))
                }
                .popover(isPresented: $showSummaryMenu) {
                    DimeLogSummaryPicker(summary: $summary, showMenu: $showSummaryMenu)
                }
                Button {
                    showMenu = true
                } label: {
                    Text(timeframe.title)
                        .padding(2)
                        .padding(.horizontal, 6)
                        .font(.system(.body, design: .rounded).weight(.medium))
                        .foregroundColor(Color.PrimaryText)
                        .overlay(Capsule().stroke(Color.Outline, lineWidth: 1.3))
                }
                .popover(isPresented: $showMenu) {
                    DimeLogTimePicker(timeframe: $timeframe, showMenu: $showMenu)
                }
            }
            Text(total, format: .currency(code: "EUR"))
                .font(.system(size: 50, weight: .regular, design: .rounded))
                .foregroundColor(Color.PrimaryText)
                .minimumScaleFactor(0.5)
                .lineLimit(1)
        }
        .padding([.bottom, .horizontal], 20)
        .frame(height: 170)
    }

    private var total: Double {
        switch summary {
        case .net: return totals.net
        case .income: return totals.income
        case .expense: return totals.expenses
        }
    }
}

private struct DimeLogSummaryPicker: View {
    @Binding var summary: DimeLogSummary
    @Binding var showMenu: Bool

    var body: some View {
        VStack(alignment: .leading, spacing: 1) {
            ForEach(DimeLogSummary.allCases) { item in
                Button {
                    withAnimation(.easeIn(duration: 0.15)) { summary = item }
                    showMenu = false
                } label: {
                    HStack {
                        Text(item.title)
                        Spacer()
                        if summary == item { Image(systemName: "checkmark") }
                    }
                    .padding(5)
                }
            }
        }
        .font(.system(.body, design: .rounded).weight(.medium))
        .foregroundColor(Color("AlwaysDarkBackground"))
        .padding(4)
        .frame(width: 150)
        .background(RoundedRectangle(cornerRadius: 9).fill(Color("AlwaysLightBackground")).shadow(color: .gray.opacity(0.25), radius: 6))
    }
}

private enum DimeLogSummary: CaseIterable, Identifiable, Hashable {
    case net, income, expense
    var id: Self { self }
    var title: LocalizedStringKey {
        switch self {
        case .net: return "Dime Log Net Total"
        case .income: return "Dime Log Earned"
        case .expense: return "Dime Log Spent"
        }
    }
}

extension DimeLogDataAdapter.Timeframe {
    var title: LocalizedStringKey {
        switch self {
        case .today: return "Dime Log Today"
        case .week: return "Dime Log This Week"
        case .month: return "Dime Log This Month"
        case .year: return "Dime Log This Year"
        case .all: return "Dime Log All Time"
        }
    }
}
