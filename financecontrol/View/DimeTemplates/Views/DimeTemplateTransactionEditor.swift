// Source-driven adaptation of Dime Views/TemplateTransactionView.swift.
// Dime layout/interactions are retained; bindings target local TransactionTemplateEntity CRUD.
import SwiftUI

struct DimeTemplateTransactionEditor: View {
    @EnvironmentObject private var coreDataModel: CoreDataModel
    @Environment(\.dismiss) private var dismiss
    @FetchRequest(sortDescriptors: [SortDescriptor(\CategoryEntity.name)], predicate: NSPredicate(format: "isShadowed == false")) private var categories: FetchedResults<CategoryEntity>
    let template: TransactionTemplateEntity?
    @State private var name: String
    @State private var note: String
    @State private var amount: Double
    @State private var category: CategoryEntity?
    @State private var kind: DimeTransactionDataAdapter.Kind
    @State private var showCategoryPicker = false
    @State private var showDelete = false
    @State private var recurrence: DimeRecurrenceFrequency = .none
    @State private var recurrenceInterval = 1
    @Namespace private var animation

    init(template: TransactionTemplateEntity? = nil) {
        self.template = template
        _name = State(initialValue: template?.wrappedName ?? "")
        _note = State(initialValue: template?.note ?? "")
        _amount = State(initialValue: template?.amount ?? 0)
        _category = State(initialValue: template?.category)
        _kind = State(initialValue: template?.isIncome == true ? .income : .expense)
    }

    var body: some View {
        VStack(spacing: 8) {
            // Original Dime TemplateTransactionView income/expense capsule and top actions.
            ZStack {
                HStack(spacing: 0) {
                    ForEach(DimeTransactionDataAdapter.Kind.allCases) { item in
                        Text(item == .expense ? "Dime Transaction Expense" : "Dime Transaction Income")
                            .font(.system(size: 18, weight: .semibold, design: .rounded))
                            .foregroundColor(kind == item ? Color.PrimaryText : Color.SubtitleText)
                            .padding(6).padding(.horizontal, 8).contentShape(Rectangle())
                            .background { if kind == item { Capsule().fill(Color.SecondaryBackground).matchedGeometryEffect(id: "TAB1", in: animation) } }
                            .onTapGesture { withAnimation(.easeIn(duration: 0.15)) { kind = item; category = nil } }
                    }
                }.padding(3).overlay(Capsule().stroke(Color.Outline.opacity(0.4), lineWidth: 1.3))
                HStack { Button { dismiss() } label: { Image(systemName: "xmark").font(.system(.subheadline, design: .rounded).weight(.semibold)).foregroundColor(Color.SubtitleText).padding(7).background(Color.SecondaryBackground, in: Circle()) }; Spacer(); if template != nil { Button { showDelete = true } label: { Image(systemName: "trash.fill").foregroundColor(Color.AlertRed).padding(7).background(Color.AlertRed.opacity(0.23), in: Circle()) } } }
            }.padding(.horizontal, 20).padding(.top, 14)

            Text(amount, format: .currency(code: "EUR")).font(.system(size: 56, weight: .regular, design: .rounded)).foregroundColor(Color.PrimaryText)
            TextField("Dime Templates Name", text: $name).font(.system(.body, design: .rounded)).padding(14).background(Color.SecondaryBackground, in: RoundedRectangle(cornerRadius: 12, style: .continuous))
            TextField("Dime Transaction Note", text: $note).font(.system(.body, design: .rounded)).padding(14).background(Color.SecondaryBackground, in: RoundedRectangle(cornerRadius: 12, style: .continuous))
            Button { showCategoryPicker = true } label: { HStack { Text(category?.name ?? String(localized: "Dime Transaction Category")); Spacer(); Image(systemName: "chevron.down") }.font(.system(.body, design: .rounded).weight(.medium)).padding(14).foregroundColor(Color.PrimaryText).background(Color.SecondaryBackground, in: RoundedRectangle(cornerRadius: 12, style: .continuous)) }.padding(.horizontal, 20)
            Spacer()
            DimeNumberPad(price: $amount, category: $category, requiresCategory: true, isEditingDecimal: .constant(false), decimalValuesAssigned: .constant(.none), submit: save).frame(height: 290).padding(.horizontal, 20)
        }
        .background(Color.PrimaryBackground)
        .sheet(isPresented: $showCategoryPicker) { DimeTransactionCategoryPicker(category: $category, showPicker: $showCategoryPicker, categories: Array(categories)) }
        .confirmationDialog("Dime Templates Delete Confirmation", isPresented: $showDelete, titleVisibility: .visible) { Button("Dime Templates Delete", role: .destructive) { if let template { coreDataModel.deleteTransactionTemplate(template) }; dismiss() } }
    }

    private func save() {
        guard let categoryID = category?.id else { return }
        let value = TransactionTemplateLocal(name: name, amount: amount, isIncome: kind == .income, categoryID: categoryID, note: note, order: template?.order ?? Int32(coreDataModel.fetchTransactionTemplates().count))
        if let template { coreDataModel.editTransactionTemplate(template, with: value) } else { coreDataModel.addTransactionTemplate(value) }
        dismiss()
    }
}
