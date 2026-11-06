// Adapted from Dime TemplateTransactionView's editor/list visual conventions.
import SwiftUI
import CoreData

struct DimeTemplatesView: View {
 @EnvironmentObject private var coreDataModel: CoreDataModel
 @Environment(\.dismiss) private var dismiss
 @FetchRequest(sortDescriptors:[NSSortDescriptor(key:"order",ascending:true)]) private var templates: FetchedResults<TransactionTemplateEntity>
 let apply: (TransactionTemplateEntity) -> Void
 @State private var templateToDelete: TransactionTemplateEntity?
 @State private var templateToEdit: TransactionTemplateEntity?
 var body: some View { NavigationStack { Group { if templates.isEmpty { ContentUnavailableView("Dime Templates Empty",systemImage:"rectangle.stack",description:Text("Dime Templates Empty Description")) } else { List { ForEach(templates) { t in Button { apply(t); dismiss() } label: { HStack { VStack(alignment:.leading) { Text(t.wrappedName).font(.system(.body,design:.rounded).weight(.semibold)); Text(t.note ?? t.category?.name ?? "").font(.system(.subheadline,design:.rounded)).foregroundColor(Color.SubtitleText) }; Spacer(); Text(t.amount,format:.currency(code:"EUR")).foregroundColor(t.isIncome ? Color.IncomeGreen : Color.PrimaryText) } }.contextMenu { Button("Dime Templates Apply") { apply(t); dismiss() }; Button("Dime Templates Edit") { templateToEdit=t }; Button("Dime Templates Delete",role:.destructive) { templateToDelete=t } } } .onMove { indices, destination in var ordered = Array(templates); ordered.move(fromOffsets: indices, toOffset: destination); coreDataModel.reorderTransactionTemplates(ordered) } } } }.navigationTitle("Dime Templates Saved").toolbar { ToolbarItem(placement:.cancellationAction) { Button("Dime Templates Cancel") { dismiss() } }; ToolbarItem(placement:.primaryAction) { EditButton() } }.confirmationDialog("Dime Templates Delete Confirmation", isPresented: Binding(get: { templateToDelete != nil }, set: { if !$0 { templateToDelete = nil } }), titleVisibility: .visible, presenting: templateToDelete) { t in Button("Dime Templates Delete", role: .destructive) { coreDataModel.deleteTransactionTemplate(t); templateToDelete = nil } } }
 .sheet(item: $templateToEdit) { template in DimeSaveTemplateView(template: template, amount: template.amount, kind: template.isIncome ? .income : .expense, category: template.category, note: template.note ?? "").environmentObject(coreDataModel) }
}

struct DimeSaveTemplateView: View {
 @EnvironmentObject private var coreDataModel: CoreDataModel
 @Environment(\.dismiss) private var dismiss
 let template: TransactionTemplateEntity?
 let amount: Double; let kind: DimeTransactionDataAdapter.Kind; let category: CategoryEntity?; let note: String
 @State private var name: String
 init(template: TransactionTemplateEntity? = nil, amount: Double, kind: DimeTransactionDataAdapter.Kind, category: CategoryEntity?, note: String) { self.template=template; self.amount=amount; self.kind=kind; self.category=category; self.note=note; _name=State(initialValue: template?.wrappedName ?? "") }
 var body: some View { NavigationStack { Form { TextField("Dime Templates Name",text:$name) }.navigationTitle("Dime Templates Create").toolbar { ToolbarItem(placement:.cancellationAction){Button("Dime Templates Cancel"){dismiss()}}; ToolbarItem(placement:.primaryAction){Button("Dime Templates Save"){ let value = TransactionTemplateLocal(name:name,amount:amount,isIncome:kind == .income,categoryID:category?.id,note:note,order: template?.order ?? Int32(coreDataModel.fetchTransactionTemplates().count)); if let template { coreDataModel.editTransactionTemplate(template, with: value) } else { coreDataModel.addTransactionTemplate(value) }; dismiss() }.disabled(name.trimmingCharacters(in:.whitespacesAndNewlines).isEmpty || amount <= 0 || category == nil) } } } }
}
