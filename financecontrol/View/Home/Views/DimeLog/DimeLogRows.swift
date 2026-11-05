//
//  DimeLogRows.swift
//  Squirrel
//
//  Directly adapted from transaction list, search, and row components in Dime LogView.
//

import SwiftUI

struct DimeLogTransactionList: View {
    let days: [DimeLogDataAdapter.Day]
    let coreDataModel: CoreDataModel
    let bottomEdge: CGFloat

    var body: some View {
        LazyVStack(spacing: 0) {
            if days.isEmpty {
                DimeLogNoResultsView()
            }
            ForEach(days) { day in
                VStack(spacing: 0) {
                    HStack {
                        Text(day.id, format: .dateTime.weekday(.abbreviated).day().month())
                        Spacer()
                        Text(day.total, format: .currency(code: "EUR"))
                            .layoutPriority(1)
                    }
                    .font(.system(.callout, design: .rounded).weight(.semibold))
                    .foregroundColor(Color.SubtitleText)
                    DimeLogLine()
                        .stroke(Color.Outline, style: StrokeStyle(lineWidth: 1.3, lineCap: .round))
                    ForEach(day.spendings) { spending in
                        DimeLogTransactionRow(spending: spending, coreDataModel: coreDataModel)
                    }
                }
                .padding(.bottom, 18)
            }
        }
    }
}

private struct DimeLogTransactionRow: View {
    @Environment(\.layoutDirection) private var layoutDirection
    let spending: SpendingEntity
    let coreDataModel: CoreDataModel
    @State private var showDeleteConfirmation = false

    private var amount: Double { spending.amountWithReturns }
    private var categoryColor: String { spending.category?.color ?? "#FFFFFF" }
    private var categoryName: String { spending.category?.name ?? "" }
    private var gestureEdge: HorizontalEdge { layoutDirection == .rightToLeft ? .leading : .trailing }

    var body: some View {
        HStack(spacing: 12) {
            DimeLogCategoryBadge(name: categoryName, color: categoryColor)
            VStack(alignment: .leading, spacing: 2) {
                Text(spending.comment?.isEmpty == false ? spending.comment! : categoryName)
                    .font(.system(.body, design: .rounded).weight(.medium))
                    .foregroundColor(Color.PrimaryText)
                    .lineLimit(1)
                Text(spending.wrappedDate, format: .dateTime.hour().minute())
                    .font(.system(.subheadline, design: .rounded).weight(.medium))
                    .foregroundColor(Color.SubtitleText)
                    .lineLimit(1)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            Text("-\(amount, format: .currency(code: \"EUR\"))")
                .font(.system(.title3, design: .rounded).weight(.medium))
                .foregroundColor(Color.PrimaryText)
                .minimumScaleFactor(0.7)
                .lineLimit(1)
                .layoutPriority(1)
        }
        .padding(.vertical, 8)
        .padding(.horizontal, 10)
        .contentShape(RoundedRectangle(cornerRadius: 10))
        .contextMenu {
            Button(role: .destructive) { showDeleteConfirmation = true } label: {
                Label("Dime Log Delete", systemImage: "xmark.bin")
            }
        }
        .swipeActions(edge: gestureEdge, allowsFullSwipe: false) {
            Button(role: .destructive) { showDeleteConfirmation = true } label: {
                Label("Dime Log Delete", systemImage: "trash")
            }
        }
        .confirmationDialog("Dime Log Delete Confirmation", isPresented: $showDeleteConfirmation, titleVisibility: .visible) {
            Button("Dime Log Delete", role: .destructive) {
                coreDataModel.deleteSpending(spending)
            }
        }
        .accessibilityElement(children: .ignore)
        .accessibilityLabel("\(spending.comment ?? categoryName), \(amount.formatted(.currency(code: \"EUR\"))), \(categoryName)")
    }
}

private struct DimeLogCategoryBadge: View {
    let name: String
    let color: String

    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 9, style: .continuous)
                .fill(blend(over: Color(hex: color), withAlpha: 0.73))
            Text(String(name.prefix(1)))
                .font(.system(.title3))
                .padding(8)
        }
    }
}

private struct DimeLogLine: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        path.move(to: CGPoint(x: rect.minX, y: rect.midY))
        path.addLine(to: CGPoint(x: rect.maxX, y: rect.midY))
        return path
    }
}

private struct DimeLogNoResultsView: View {
    var body: some View {
        VStack(spacing: 12) {
            Spacer()
            Image(systemName: "tray.full.fill")
                .font(.system(.largeTitle, design: .rounded))
                .foregroundColor(Color.SubtitleText)
            Text("Dime Log No Entries")
                .font(.system(.title3, design: .rounded).weight(.medium))
                .foregroundColor(Color.SubtitleText)
            Spacer()
        }
        .frame(maxWidth: .infinity)
        .frame(height: UIScreen.main.bounds.height * 0.7)
        .opacity(0.7)
    }
}

struct DimeLogSearchView: View {
    @Environment(\.dismiss) private var dismiss
    @Binding var query: String

    var body: some View {
        VStack(spacing: 18) {
            HStack(spacing: 9) {
                HStack {
                    Image(systemName: "magnifyingglass")
                        .foregroundColor(Color.DarkIcon.opacity(0.8))
                    TextField("Dime Log Search Placeholder", text: $query)
                        .font(.system(.body, design: .rounded).weight(.regular))
                    if !query.isEmpty {
                        Button { query = "" } label: {
                            Image(systemName: "xmark.circle.fill")
                                .foregroundColor(Color.SubtitleText)
                        }
                    }
                }
                .padding(6)
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(Color.SecondaryBackground, in: RoundedRectangle(cornerRadius: 8))
                Button("Dime Log Cancel") { dismiss() }
                    .foregroundColor(Color.PrimaryText)
                    .font(.system(.body, design: .rounded).weight(.medium))
            }
            Spacer()
        }
        .padding(15)
        .background(Color.PrimaryBackground)
    }
}
