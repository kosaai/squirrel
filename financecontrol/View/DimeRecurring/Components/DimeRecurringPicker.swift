// Directly adapted from Dime's RecurringPickerView and CustomRecurringView.
import SwiftUI

struct DimeRecurringPicker: View {
    @Binding var frequency: DimeRecurrenceFrequency
    @Binding var interval: Int
    @Binding var showMenu: Bool
    @Binding var showCustom: Bool
    @Namespace private var animation

    var body: some View {
        VStack(alignment: .leading, spacing: 1) {
            ForEach(DimeRecurrenceFrequency.allCases) { option in
                HStack {
                    Text(option.title).font(.system(.body, design: .rounded).weight(.medium))
                    Spacer()
                    if frequency == option && interval == 1 { Image(systemName: "checkmark") }
                }
                .padding(5).frame(maxWidth: .infinity, alignment: .leading)
                .background { if frequency == option && interval == 1 { RoundedRectangle(cornerRadius: 6).fill(Color("AlwaysLightSecondaryBackground")).matchedGeometryEffect(id: "TAB", in: animation) } }
                .contentShape(Rectangle())
                .onTapGesture { withAnimation(.easeIn(duration: 0.15)) { frequency = option; interval = 1 }; showMenu = false }
            }
            HStack {
                Text(interval == 1 ? "Dime Recurring Custom" : String(localized: "Dime Recurring Every \(interval) \(frequency.unit)"))
                Spacer()
                if interval > 1 { Image(systemName: "checkmark") }
            }
            .font(.system(.body, design: .rounded).weight(.medium)).padding(5).contentShape(Rectangle())
            .onTapGesture { if interval == 1 { frequency = .weekly; interval = 2 }; showCustom = true }
        }
        .foregroundColor(Color("AlwaysDarkBackground")).padding(4).frame(width: 170)
        .background(RoundedRectangle(cornerRadius: 9).fill(Color("AlwaysLightBackground")).shadow(color: .gray.opacity(0.25), radius: 6))
    }
}

struct DimeCustomRecurringView: View {
    @Binding var frequency: DimeRecurrenceFrequency
    @Binding var interval: Int
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        VStack(spacing: 35) {
            HStack {
                Button { dismiss() } label: { Image(systemName: "xmark").foregroundColor(Color.SubtitleText).padding(7).background(Color.SecondaryBackground, in: Circle()) }
                Spacer()
                Text("Dime Recurring Custom Interval").font(.system(.body, design: .rounded).weight(.semibold))
                Spacer()
                Button { dismiss() } label: { Image(systemName: "checkmark").foregroundColor(Color.IncomeGreen).padding(7).background(Color.IncomeGreen.opacity(0.23), in: Circle()) }
            }
            Stepper(value: $interval, in: 1...30) { Text("Dime Recurring Every \(interval) \(frequency.unit)").font(.system(.title3, design: .rounded).weight(.medium)) }
            Picker("Dime Recurring Frequency", selection: $frequency) {
                Text(DimeRecurrenceFrequency.daily.title).tag(DimeRecurrenceFrequency.daily)
                Text(DimeRecurrenceFrequency.weekly.title).tag(DimeRecurrenceFrequency.weekly)
                Text(DimeRecurrenceFrequency.monthly.title).tag(DimeRecurrenceFrequency.monthly)
            }.pickerStyle(.segmented)
        }.padding(13).frame(maxHeight: .infinity, alignment: .top)
    }
}

extension DimeRecurrenceFrequency {
    var title: LocalizedStringKey { switch self { case .none: return "Dime Recurring None"; case .daily: return "Dime Recurring Daily"; case .weekly: return "Dime Recurring Weekly"; case .monthly: return "Dime Recurring Monthly" } }
    var unit: String { switch self { case .none: return ""; case .daily: return String(localized: "Dime Recurring Days"); case .weekly: return String(localized: "Dime Recurring Weeks"); case .monthly: return String(localized: "Dime Recurring Months") } }
}
