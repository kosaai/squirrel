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

    let transactionToEdit: DimeTransactionDataAdapter.Record?
    @StateObject private var adapter = DimeTransactionDataAdapter()
    @State private var note: String
    @State private var amount: Double
    @State private var category: CategoryEntity?
    @State private var date: Date
    @State private var showCategoryPicker = false
    @State private var isEditingDecimal = false
    @State private var decimalValuesAssigned: DimeAssignedDecimal = .none
    @State private var saveErrorMessage = ""
    @State private var showSaveError = false
    @FocusState private var isEditingNote: Bool

    init(spendingToEdit: SpendingEntity?) {
        self.init(transactionToEdit: spendingToEdit.map(DimeTransactionDataAdapter.Record.expense))
    }

    init(transactionToEdit: DimeTransactionDataAdapter.Record? = nil) {
        self.transactionToEdit = transactionToEdit
        _note = State(initialValue: transactionToEdit?.note ?? "")
        _amount = State(initialValue: transactionToEdit?.amount ?? 0)
        _category = State(initialValue: transactionToEdit?.category)
        _date = State(initialValue: transactionToEdit?.date ?? .now)
    }

    /// New editor presentations are always expenses. Historical Log records retain their persisted type.
    private var kind: DimeTransactionDataAdapter.Kind {
        transactionToEdit?.kind ?? .expense
    }

    private var suggestions: [DimeTransactionDataAdapter.Record] {
        adapter.suggestions(note: note, kind: kind, from: coreDataModel)
    }

    var body: some View {
        VStack(spacing: 0) {
            DimeTransactionHeader(isEditing: transactionToEdit != nil, dismiss: dismiss, save: save, isSaving: adapter.isSaving)
            ScrollViewReader { proxy in
                ScrollView(showsIndicators: false) {
                    VStack(spacing: 18) {
                        Text(amount, format: .currency(code: "EUR"))
                            .font(.system(size: 50, weight: .regular, design: .rounded))
                            .foregroundColor(Color.PrimaryText)
                            .minimumScaleFactor(0.5)
                            .lineLimit(1)
                        DimeSuggestedTransactions(note: $note, amount: $amount, category: $category, allowsCategoryAssignment: kind == .income, suggestions: suggestions)
                        if kind == .income {
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
                        }
                        TextField("Dime Transaction Note", text: $note)
                            .font(.system(.body, design: .rounded))
                            .padding(14)
                            .background(Color.SecondaryBackground, in: RoundedRectangle(cornerRadius: 12, style: .continuous))
                            .focused($isEditingNote)
                            .submitLabel(.done)
                            .onSubmit { isEditingNote = false }
                            .id("dime-transaction-note")
                        DatePicker("Dime Transaction Date", selection: $date)
                            .font(.system(.body, design: .rounded))
                            .tint(Color.DarkIcon)
                    }
                    .padding(.horizontal, 20)
                }
                .onChange(of: isEditingNote) { isEditing in
                    guard isEditing else { return }
                    withAnimation(.easeInOut(duration: 0.2)) {
                        proxy.scrollTo("dime-transaction-note", anchor: .center)
                    }
                }
            }
            if !isEditingNote {
                DimeNumberPad(
                    price: $amount,
                    category: $category,
                    requiresCategory: kind == .income,
                    isEditingDecimal: $isEditingDecimal,
                    decimalValuesAssigned: $decimalValuesAssigned,
                    submit: save
                )
                .frame(height: 290)
                .padding(.horizontal, 20)
                .disabled(adapter.isSaving)
            }
        }
        .background(Color.PrimaryBackground)
        .toolbar {
            ToolbarItemGroup(placement: .keyboard) {
                Spacer()
                Button("Dime Transaction Dismiss Keyboard", systemImage: "keyboard.chevron.compact.down") {
                    isEditingNote = false
                }
            }
        }
        .sheet(isPresented: $showCategoryPicker) {
            DimeTransactionCategoryPicker(category: $category, showPicker: $showCategoryPicker, categories: coreDataModel.savedCategories)
        }
        .alert("Dime Transaction Save Failed", isPresented: $showSaveError) {
            Button("Dime Transaction Error OK", role: .cancel) {}
        } message: {
            Text(saveErrorMessage)
        }
    }

    private func save() {
        adapter.save(
            existing: transactionToEdit,
            kind: kind,
            amount: amount,
            note: note,
            category: category,
            date: date,
            coreDataModel: coreDataModel
        ) { result in
            switch result {
            case .success:
                dismiss()
            case .failure(let error):
                saveErrorMessage = NSLocalizedString(error.localizationKey, comment: "")
                showSaveError = true
            }
        }
    }
}

private struct DimeTransactionHeader: View {
    let isEditing: Bool
    let dismiss: DismissAction
    let save: () -> Void
    let isSaving: Bool

    var body: some View {
        HStack {
            Button("Dime Transaction Cancel") { dismiss() }
            Spacer()
            Text(isEditing ? "Dime Transaction Edit" : "Dime Transaction Add")
                .font(.system(.title3, design: .rounded).weight(.semibold))
                .foregroundColor(Color.PrimaryText)
            Spacer()
            Button("Dime Transaction Save", action: save)
                .disabled(isSaving)
        }
        .font(.system(.body, design: .rounded).weight(.medium))
        .foregroundColor(Color.DarkIcon)
        .padding(.horizontal, 20)
        .padding(.vertical, 14)
    }
}
