//
//  TransactionView.swift
//  Squirrel
//
//  Directly adapted from app/dime/Views/TransactionView.swift (Dime).
//  Local expense persistence is delegated to DimeTransactionDataAdapter.
//

import SwiftUI

struct DimeTransactionView: View {
    @EnvironmentObject private var coreDataModel: CoreDataModel
    @Environment(\.dismiss) private var dismiss
    @FetchRequest(sortDescriptors: [SortDescriptor(\CategoryEntity.name)], predicate: NSPredicate(format: "isShadowed == false"))
    private var categories: FetchedResults<CategoryEntity>

    let transactionToEdit: DimeTransactionDataAdapter.Record?
    @StateObject private var adapter = DimeTransactionDataAdapter()
    @State private var note: String
    @State private var amount: Double
    @State private var category: CategoryEntity?
    @State private var date: Date
    @State private var showCategoryPicker = false
    @State private var isEditingDecimal = false
    @State private var decimalValuesAssigned: DimeAssignedDecimal = .none
    @State private var kind: DimeTransactionDataAdapter.Kind
    @State private var recurrence: DimeRecurrenceFrequency = .none
    @State private var recurrenceInterval = 1
    @State private var showRecurrencePicker = false
    @State private var showCustomRecurrence = false
    @State private var showTemplates = false
    @State private var showSaveTemplate = false

    init(spendingToEdit: SpendingEntity?) {
        self.init(transactionToEdit: spendingToEdit.map(DimeTransactionDataAdapter.Record.expense))
    }

    init(transactionToEdit: DimeTransactionDataAdapter.Record? = nil) {
        self.transactionToEdit = transactionToEdit
        _note = State(initialValue: transactionToEdit?.note ?? "")
        _amount = State(initialValue: transactionToEdit?.amount ?? 0)
        _category = State(initialValue: transactionToEdit?.category)
        _date = State(initialValue: transactionToEdit?.date ?? .now)
        _kind = State(initialValue: transactionToEdit?.kind ?? .expense)
    }

    private var suggestions: [DimeTransactionDataAdapter.Record] {
        adapter.suggestions(note: note, kind: kind, from: coreDataModel)
    }

    var body: some View {
        VStack(spacing: 0) {
            DimeTransactionHeader(isEditing: transactionToEdit != nil, dismiss: dismiss, save: save)
            ScrollView(showsIndicators: false) {
                VStack(spacing: 18) {
                    DimeTransactionKindPicker(kind: $kind)
                        .disabled(transactionToEdit != nil)
                    Text(amount, format: .currency(code: "EUR"))
                        .font(.system(size: 50, weight: .regular, design: .rounded))
                        .foregroundColor(Color.PrimaryText)
                        .minimumScaleFactor(0.5)
                        .lineLimit(1)
                    DimeSuggestedTransactions(note: $note, amount: $amount, category: $category, suggestions: suggestions)
                    HStack(spacing: 10) {
                        Button { showTemplates = true } label: { Label("Dime Templates Saved", systemImage: "rectangle.stack") }
                        Button { showSaveTemplate = true } label: { Label("Dime Templates Save As", systemImage: "plus.rectangle.on.rectangle") }
                    }
                    .font(.system(.body, design: .rounded).weight(.medium))
                    .foregroundColor(Color.DarkIcon)
                    Button { showRecurrencePicker = true } label: {
                        HStack { Text(recurrence == .none ? String(localized: "Dime Recurring None") : "\(String(localized: "Dime Recurring Every")) \(recurrenceInterval) \(recurrence.unit)"); Spacer(); Image(systemName: "repeat") }
                            .font(.system(.body, design: .rounded).weight(.medium)).padding(14).foregroundColor(recurrence == .none ? Color.PrimaryText : Color.IncomeGreen).background(Color.SecondaryBackground, in: RoundedRectangle(cornerRadius: 12, style: .continuous))
                    }
                    Button { showCategoryPicker = true } label: {
                        HStack {
                            Text(category?.name ?? String(localized: "Dime Transaction Category"))
                                .font(.system(.title3, design: .rounded).weight(.medium))
                            Spacer()
                            Image(systemName: "chevron.down")
                        }
                        .padding(.horizontal, 14)
                        .padding(.vertical, 12)
                        .foregroundColor(Color.PrimaryText)
                        .background(Color.SecondaryBackground, in: RoundedRectangle(cornerRadius: 12, style: .continuous))
                    }
                    TextField("Dime Transaction Note", text: $note)
                        .font(.system(.body, design: .rounded))
                        .padding(14)
                        .background(Color.SecondaryBackground, in: RoundedRectangle(cornerRadius: 12, style: .continuous))
                    DatePicker("Dime Transaction Date", selection: $date)
                        .font(.system(.body, design: .rounded))
                        .tint(Color.DarkIcon)
                }
                .padding(.horizontal, 20)
            }
            DimeNumberPad(
                price: $amount,
                category: $category,
                isEditingDecimal: $isEditingDecimal,
                decimalValuesAssigned: $decimalValuesAssigned,
                submit: save
            )
            .frame(height: 290)
            .padding(.horizontal, 20)
        }
        .background(Color.PrimaryBackground)
        .sheet(isPresented: $showCategoryPicker) {
            DimeTransactionCategoryPicker(category: $category, showPicker: $showCategoryPicker, categories: Array(categories))
        }
        .popover(isPresented: $showRecurrencePicker) {
            DimeRecurringPicker(frequency: $recurrence, interval: $recurrenceInterval, showMenu: $showRecurrencePicker, showCustom: $showCustomRecurrence)
        }
        .sheet(isPresented: $showCustomRecurrence) {
            DimeCustomRecurringView(frequency: $recurrence, interval: $recurrenceInterval)
        }
        .sheet(isPresented: $showTemplates) {
            DimeTemplatesView { template in
                amount = template.amount
                note = template.note ?? ""
                category = template.category
                kind = template.isIncome ? .income : .expense
                recurrence = .none
                recurrenceInterval = 1
            }
            .environmentObject(coreDataModel)
        }
        .sheet(isPresented: $showSaveTemplate) {
            DimeSaveTemplateView(amount: amount, kind: kind, category: category, note: note)
                .environmentObject(coreDataModel)
        }
    }

    private func save() {
        if transactionToEdit == nil && (recurrence != .none || date > .now) {
            adapter.saveScheduled(amount: amount, note: note, category: category, date: date, kind: kind, frequency: recurrence, interval: recurrenceInterval, coreDataModel: coreDataModel)
        } else {
            adapter.save(existing: transactionToEdit, kind: kind, amount: amount, note: note, category: category, date: date, coreDataModel: coreDataModel)
        }
        dismiss()
    }
}

private struct DimeTransactionKindPicker: View {
    @Binding var kind: DimeTransactionDataAdapter.Kind
    @Namespace private var animation

    var body: some View {
        HStack(spacing: 0) {
            ForEach(DimeTransactionDataAdapter.Kind.allCases) { item in
                Text(item == .expense ? "Dime Transaction Expense" : "Dime Transaction Income")
                    .font(.system(.body, design: .rounded).weight(.semibold))
                    .foregroundColor(kind == item ? Color.PrimaryText : Color.SubtitleText)
                    .padding(6)
                    .frame(width: 100)
                    .contentShape(Rectangle())
                    .background {
                        if kind == item {
                            Capsule().fill(Color.SecondaryBackground).matchedGeometryEffect(id: "transaction-kind", in: animation)
                        }
                    }
                    .onTapGesture { withAnimation(.easeIn(duration: 0.15)) { kind = item } }
            }
        }
        .padding(3)
        .overlay(Capsule().stroke(Color.Outline.opacity(0.4), lineWidth: 1.3))
    }
}

private struct DimeTransactionHeader: View {
    let isEditing: Bool
    let dismiss: DismissAction
    let save: () -> Void

    var body: some View {
        HStack {
            Button("Dime Transaction Cancel") { dismiss() }
            Spacer()
            Text(isEditing ? "Dime Transaction Edit" : "Dime Transaction Add")
                .font(.system(.title3, design: .rounded).weight(.semibold))
                .foregroundColor(Color.PrimaryText)
            Spacer()
            Button("Dime Transaction Save", action: save)
        }
        .font(.system(.body, design: .rounded).weight(.medium))
        .foregroundColor(Color.DarkIcon)
        .padding(.horizontal, 20)
        .padding(.vertical, 14)
    }
}
