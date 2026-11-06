//
//  DimeLogView.swift
//  Squirrel
//
//  Directly adapted from app/dime/Views/LogView.swift (Dime).
//  CloudKit sync and Dime persistence calls are intentionally excluded.
//

import SwiftUI

struct DimeLogView: View {
    @EnvironmentObject private var coreDataModel: CoreDataModel
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

    var topEdge: CGFloat = 0
    var bottomEdge: CGFloat = 0

    private var spendings: [SpendingEntity] {
        adapter.filteredSpendings(from: coreDataModel, query: searchQuery, category: filter == .category ? category : nil, dateRange: activeDateRange)
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
            if coreDataModel.savedSpendings.isEmpty {
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
                        categories: coreDataModel.savedCategories
                    )
                    .padding(.horizontal, 25)
                    .padding(.top, topEdge + 10)

                    ScrollView(showsIndicators: false) {
                        if filter == .all {
                            DimeLogInsights(
                                total: adapter.total(from: adapter.allSpendings(from: coreDataModel), timeframe: timeframe),
                                timeframe: $timeframe
                            )
                        }

                        DimeLogTransactionList(
                            days: adapter.groupedDays(spendings),
                            coreDataModel: coreDataModel,
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
    let total: Double
    @Binding var timeframe: DimeLogDataAdapter.Timeframe
    @State private var showMenu = false

    var body: some View {
        VStack(spacing: 2) {
            HStack(spacing: 4) {
                Text("Dime Log Spent")
                    .font(.system(.body, design: .rounded).weight(.medium))
                    .foregroundColor(Color.PrimaryText.opacity(0.9))
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
