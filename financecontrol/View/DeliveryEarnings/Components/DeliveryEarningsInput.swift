//
//  DeliveryEarningsInput.swift
//  Squirrel
//

import SwiftUI

enum DeliveryEarningsField: Hashable {
    case orderRate, kilometerRate, orders, kilometers, tips, cashReceived, cashExpense
}

struct DeliveryEarningsInput: View {
    let title: String
    let symbol: String?
    let unit: String?
    let keyboardType: UIKeyboardType
    let field: DeliveryEarningsField
    @Binding var text: String
    @FocusState.Binding var focusedField: DeliveryEarningsField?

    var body: some View {
        VStack(alignment: .leading, spacing: 7) {
            if let symbol, !title.isEmpty {
                Label(title, systemImage: symbol)
                    .labelStyle(.titleAndIcon)
                    .font(.footnote.weight(.semibold))
                    .foregroundStyle(.primary)
            } else if !title.isEmpty {
                Text(title)
                    .font(.footnote.weight(.semibold))
                    .foregroundStyle(.primary)
            }

            HStack(spacing: 6) {
                TextField("—", text: $text)
                    .focused($focusedField, equals: field)
                    .keyboardType(keyboardType)
                    .textInputAutocapitalization(.never)
                    .autocorrectionDisabled()
                    .multilineTextAlignment(.trailing)
                    .font(.system(.title3, design: .rounded).weight(.semibold))
                    .foregroundStyle(.primary)
                    .accessibilityLabel(title)

                if let unit {
                    Text(unit)
                        .font(.subheadline.weight(.medium))
                        .foregroundStyle(.secondary)
                        .accessibilityHidden(true)
                }
            }
            .frame(minHeight: 44)
            .padding(.horizontal, 10)
            .background(DeliveryEarningsStyle.fieldBackground, in: RoundedRectangle(cornerRadius: 12, style: .continuous))
            .overlay {
                RoundedRectangle(cornerRadius: 12, style: .continuous)
                    .stroke(focusedField == field ? DeliveryEarningsStyle.accent : .clear, lineWidth: 1.5)
            }
        }
    }
}

struct DeliveryEarningsWorkCard: View {
    let title: String
    let symbol: String
    let unit: String?
    let keyboardType: UIKeyboardType
    let field: DeliveryEarningsField
    @Binding var text: String
    @FocusState.Binding var focusedField: DeliveryEarningsField?

    var body: some View {
        DeliveryEarningsInput(
            title: title,
            symbol: symbol,
            unit: unit,
            keyboardType: keyboardType,
            field: field,
            text: $text,
            focusedField: $focusedField
        )
        .padding(11)
        .background(DeliveryEarningsStyle.workCardBackground, in: RoundedRectangle(cornerRadius: 15, style: .continuous))
    }
}
