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

    let spendingToEdit: SpendingEntity?
    @StateObject private var adapter = DimeTransactionDataAdapter()
    @State private var note: String
    @State private var amount: Double
    @State private var category: CategoryEntity?
    @State private var date: Date
    @State private var showCategoryPicker = false
    @State private var isEditingDecimal = false
    @State private var decimalValuesAssigned: DimeAssignedDecimal = .none

    init(spendingToEdit: SpendingEntity? = nil) {
        self.spendingToEdit = spendingToEdit
        _note = State(initialValue: spendingToEdit?.comment ?? "")
        _amount = State(initialValue: spendingToEdit?.amount ?? 0)
        _category = State(initialValue: spendingToEdit?.category)
        _date = State(initialValue: spendingToEdit?.wrappedDate ?? .now)
    }

    private var suggestions: [SpendingEntity] {
        adapter.suggestions(note: note, from: coreDataModel.savedSpendings)
    }

    var body: some View {
        VStack(spacing: 0) {
            DimeTransactionHeader(isEditing: spendingToEdit != nil, dismiss: dismiss, save: save)
            ScrollView(showsIndicators: false) {
                VStack(spacing: 18) {
                    Text(amount, format: .currency(code: "EUR"))
                        .font(.system(size: 50, weight: .regular, design: .rounded))
                        .foregroundColor(Color.PrimaryText)
                        .minimumScaleFactor(0.5)
                        .lineLimit(1)
                    DimeSuggestedTransactions(note: $note, amount: $amount, category: $category, suggestions: suggestions)
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
                    DatePicker("Dime Transaction Date", selection: $date, in: ...Date.now)
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
    }

    private func save() {
        adapter.save(existing: spendingToEdit, amount: amount, note: note, category: category, date: date, coreDataModel: coreDataModel)
        dismiss()
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
