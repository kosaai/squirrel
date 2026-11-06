// Dime's original TemplateTransactionView is presented by this manager/editor flow.
import SwiftUI
import CoreData

struct DimeTemplatesView: View {
    @EnvironmentObject private var coreDataModel: CoreDataModel
    @Environment(\.dismiss) private var dismiss
    @FetchRequest(sortDescriptors: [NSSortDescriptor(key: "order", ascending: true)]) private var templates: FetchedResults<TransactionTemplateEntity>
    let apply: (TransactionTemplateEntity) -> Void
    @State private var templateToDelete: TransactionTemplateEntity?
    @State private var templateToEdit: TransactionTemplateEntity?
    @State private var createTemplate = false

    var body: some View {
        NavigationStack {
            Group {
                if templates.isEmpty {
                    ContentUnavailableView("Dime Templates Empty", systemImage: "rectangle.stack", description: Text("Dime Templates Empty Description"))
                } else {
                    List {
                        ForEach(templates) { template in
                            Button { apply(template); dismiss() } label: { row(template) }
                                .contextMenu {
                                    Button("Dime Templates Apply") { apply(template); dismiss() }
                                    Button("Dime Templates Edit") { templateToEdit = template }
                                    Button("Dime Templates Delete", role: .destructive) { templateToDelete = template }
                                }
                        }
                        .onMove { indices, destination in
                            var ordered = Array(templates)
                            ordered.move(fromOffsets: indices, toOffset: destination)
                            coreDataModel.reorderTransactionTemplates(ordered)
                        }
                    }
                }
            }
            .navigationTitle("Dime Templates Saved")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) { Button("Dime Templates Cancel") { dismiss() } }
                ToolbarItem(placement: .primaryAction) {
                    HStack { Button { createTemplate = true } label: { Image(systemName: "plus") }; EditButton() }
                }
            }
        }
        .sheet(item: $templateToEdit) { DimeTemplateTransactionEditor(template: $0).environmentObject(coreDataModel) }
        .sheet(isPresented: $createTemplate) { DimeTemplateTransactionEditor().environmentObject(coreDataModel) }
        .confirmationDialog("Dime Templates Delete Confirmation", isPresented: Binding(get: { templateToDelete != nil }, set: { if !$0 { templateToDelete = nil } }), titleVisibility: .visible, presenting: templateToDelete) { template in
            Button("Dime Templates Delete", role: .destructive) { coreDataModel.deleteTransactionTemplate(template); templateToDelete = nil }
        }
    }

    private func row(_ template: TransactionTemplateEntity) -> some View {
        HStack { VStack(alignment: .leading) { Text(template.wrappedName).font(.system(.body, design: .rounded).weight(.semibold)); Text(template.note ?? template.category?.name ?? "").font(.system(.subheadline, design: .rounded)).foregroundColor(Color.SubtitleText) }; Spacer(); Text(template.amount, format: .currency(code: "EUR")).foregroundColor(template.isIncome ? Color.IncomeGreen : Color.PrimaryText) }
    }
}

// Squirrel-specific lightweight naming sheet used only by “Save as Template” from the transaction editor.
struct DimeSaveTemplateView: View {
    @EnvironmentObject private var coreDataModel: CoreDataModel
    @Environment(\.dismiss) private var dismiss
    let amount: Double; let kind: DimeTransactionDataAdapter.Kind; let category: CategoryEntity?; let note: String
    @State private var name = ""
    var body: some View { NavigationStack { Form { TextField("Dime Templates Name", text: $name) }.navigationTitle("Dime Templates Create").toolbar { ToolbarItem(placement: .cancellationAction) { Button("Dime Templates Cancel") { dismiss() } }; ToolbarItem(placement: .primaryAction) { Button("Dime Templates Save") { guard let categoryID = category?.id else { return }; coreDataModel.addTransactionTemplate(.init(name: name, amount: amount, isIncome: kind == .income, categoryID: categoryID, note: note, order: Int32(coreDataModel.fetchTransactionTemplates().count))); dismiss() }.disabled(name.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty || amount <= 0 || category == nil) } } } }
}
