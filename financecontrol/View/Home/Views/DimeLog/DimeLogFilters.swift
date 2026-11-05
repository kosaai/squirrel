//
//  DimeLogFilters.swift
//  Squirrel
//
//  Directly adapted from filter, picker, and stepper components in Dime LogView.
//

import SwiftUI

enum DimeLogFilter: String, CaseIterable, Identifiable {
    case all, category, day, week, month
    var id: String { rawValue }
    var title: LocalizedStringKey {
        switch self {
        case .all: "Dime Log All"
        case .category: "Dime Log Category"
        case .day: "Dime Log Day"
        case .week: "Dime Log Week"
        case .month: "Dime Log Month"
        }
    }
}

struct DimeLogHeader: View {
    @Binding var searchMode: Bool
    @Binding var showFilter: Bool
    @Binding var filter: DimeLogFilter
    @Binding var category: CategoryEntity?
    @Binding var date: Date
    @Binding var week: Date
    @Binding var month: Date
    let categories: [CategoryEntity]

    var body: some View {
        VStack(spacing: 18) {
            HStack {
                Button { searchMode = true } label: {
                    Image(systemName: "magnifyingglass")
                        .font(.system(.title2, design: .rounded).weight(.regular))
                        .foregroundColor(Color.DarkIcon)
                        .padding(5)
                }
                .accessibilityLabel("Dime Log Search")
                Spacer()
                if filter != .all {
                    HStack(spacing: 10) {
                        Text(filter.title)
                            .font(.system(.body, design: .rounded).weight(.medium))
                        Button { withAnimation(.easeIn(duration: 0.15)) { filter = .all } } label: {
                            Image(systemName: "xmark")
                                .font(.system(.caption, design: .rounded).weight(.regular))
                        }
                    }
                    .padding(4)
                    .padding(.horizontal, 6)
                    .background(Color.SecondaryBackground, in: RoundedRectangle(cornerRadius: 9, style: .continuous))
                    .foregroundColor(Color.PrimaryText)
                }
                Spacer()
                Button { showFilter = true } label: {
                    Image(systemName: filter == .all ? "triangle" : "triangle.tophalf.filled")
                        .font(.system(.title2, design: .rounded).weight(.regular))
                        .foregroundColor(Color.DarkIcon)
                        .rotationEffect(.degrees(180))
                        .padding(5)
                }
                .accessibilityLabel("Dime Log Filter")
                .popover(isPresented: $showFilter) {
                    DimeLogFilterPicker(filter: $filter, showMenu: $showFilter)
                }
            }

            switch filter {
            case .all: EmptyView()
            case .category: DimeLogCategoryStepper(category: $category, categories: categories)
            case .day: DimeLogDateStepper(date: $date, component: .day)
            case .week: DimeLogDateStepper(date: $week, component: .weekOfYear)
            case .month: DimeLogDateStepper(date: $month, component: .month)
            }
        }
        .frame(height: filter == .all ? 50 : 110, alignment: .top)
    }
}

private struct DimeLogFilterPicker: View {
    @Binding var filter: DimeLogFilter
    @Binding var showMenu: Bool
    @Namespace private var animation

    var body: some View {
        VStack(alignment: .leading, spacing: 1) {
            ForEach(DimeLogFilter.allCases) { item in
                HStack {
                    Text(item.title)
                        .font(.system(.body, design: .rounded).weight(.medium))
                    Spacer()
                    if filter == item { Image(systemName: "checkmark") }
                }
                .padding(5)
                .frame(maxWidth: .infinity, alignment: .leading)
                .background {
                    if filter == item {
                        RoundedRectangle(cornerRadius: 6)
                            .fill(Color("AlwaysLightSecondaryBackground"))
                            .matchedGeometryEffect(id: "TAB", in: animation)
                    }
                }
                .contentShape(Rectangle())
                .onTapGesture {
                    withAnimation(.easeIn(duration: 0.15)) { filter = item }
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) { showMenu = false }
                }
            }
        }
        .foregroundColor(Color("AlwaysDarkBackground"))
        .padding(4)
        .frame(width: 190)
        .background(RoundedRectangle(cornerRadius: 9).fill(Color("AlwaysLightBackground")).shadow(color: .gray.opacity(0.25), radius: 6))
    }
}

private struct DimeLogTimePicker: View {
    @Binding var timeframe: DimeLogDataAdapter.Timeframe
    @Binding var showMenu: Bool
    @Namespace private var animation

    var body: some View {
        VStack(alignment: .leading, spacing: 1) {
            ForEach(DimeLogDataAdapter.Timeframe.allCases, id: \.rawValue) { item in
                HStack {
                    Text(item.title).font(.system(.body, design: .rounded).weight(.medium))
                    Spacer()
                    if item == timeframe { Image(systemName: "checkmark") }
                }
                .padding(5)
                .contentShape(Rectangle())
                .onTapGesture {
                    withAnimation(.easeIn(duration: 0.15)) { timeframe = item }
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) { showMenu = false }
                }
            }
        }
        .foregroundColor(Color("AlwaysDarkBackground"))
        .padding(4)
        .frame(width: 160)
        .background(RoundedRectangle(cornerRadius: 9).fill(Color("AlwaysLightBackground")).shadow(color: .gray.opacity(0.25), radius: 6))
    }
}

private struct DimeLogCategoryStepper: View {
    @Binding var category: CategoryEntity?
    let categories: [CategoryEntity]

    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 8) {
                ForEach(categories) { item in
                    Text(item.name ?? "")
                        .font(.system(.body, design: .rounded).weight(.medium))
                        .padding(.horizontal, 11)
                        .padding(.vertical, 7)
                        .foregroundColor(category?.id == item.id ? Color(hex: item.color ?? "#FFFFFF") : Color.PrimaryText)
                        .background(category?.id == item.id ? Color(hex: item.color ?? "#FFFFFF").opacity(0.3) : Color.PrimaryBackground, in: RoundedRectangle(cornerRadius: 10, style: .continuous))
                        .overlay { if category?.id != item.id { RoundedRectangle(cornerRadius: 10, style: .continuous).strokeBorder(Color.Outline, lineWidth: 1.5) } }
                        .onTapGesture { category = item }
                }
            }
        }
        .onAppear { if category == nil { category = categories.first } }
    }
}

private struct DimeLogDateStepper: View {
    @Binding var date: Date
    let component: Calendar.Component

    var body: some View {
        HStack {
            Button { date = Calendar.current.date(byAdding: component, value: -1, to: date) ?? date } label: {
                Image(systemName: "chevron.backward")
            }
            Spacer()
            Text(date, format: format)
                .font(.system(.title3, design: .rounded).weight(.bold))
            Spacer()
            Button { if date < .now { date = Calendar.current.date(byAdding: component, value: 1, to: date) ?? date } } label: {
                Image(systemName: "chevron.forward")
            }
            .disabled(date >= .now)
        }
        .foregroundColor(Color.PrimaryText)
    }

    private var format: Date.FormatStyle {
        switch component {
        case .month: .dateTime.month(.wide).year()
        case .weekOfYear: .dateTime.day().month()
        default: .dateTime.day().month().year()
        }
    }
}
