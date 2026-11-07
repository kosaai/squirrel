//
//  NumberPad.swift
//  Squirrel
//
//  Directly adapted from Dime Components/Transactions/NumberPad.swift.
//

import SwiftUI
import UIKit

enum DimeAssignedDecimal { case none, first, second }

struct DimeNumberPad: View {
    @AppStorage("dimeNumberEntryType") private var numberEntryType = 1
    @Binding var price: Double
    @Binding var category: CategoryEntity?
    let requiresCategory: Bool
    @Binding var isEditingDecimal: Bool
    @Binding var decimalValuesAssigned: DimeAssignedDecimal
    let submit: () -> Void

    private let numbers = [[1, 2, 3], [4, 5, 6], [7, 8, 9]]

    var body: some View {
        GeometryReader { proxy in
            VStack(spacing: proxy.size.height * 0.04) {
                ForEach(numbers, id: \.self) { row in
                    HStack(spacing: proxy.size.width * 0.05) {
                        ForEach(row, id: \.self) { number in button(number, size: proxy.size) }
                    }
                }
                HStack(spacing: proxy.size.width * 0.05) {
                    Button(action: deleteLastDigit) {
                        Image(systemName: "delete.left")
                            .font(.system(size: 28, weight: .regular, design: .rounded))
                            .frame(width: proxy.size.width * 0.3, height: proxy.size.height * 0.22)
                            .background(Color.DarkBackground)
                            .foregroundColor(Color.LightIcon)
                            .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))
                    }
                    .buttonStyle(DimeNumberPadButtonStyle())
                    button(0, size: proxy.size)
                    Button(action: submit) {
                        Image(systemName: "checkmark.square.fill")
                            .font(.system(size: 30, weight: .medium, design: .rounded))
                            .frame(width: proxy.size.width * 0.3, height: proxy.size.height * 0.22)
                            .foregroundColor(Color.LightIcon)
                            .background(Color.DarkBackground, in: RoundedRectangle(cornerRadius: 10, style: .continuous))
                    }
                    .buttonStyle(DimeNumberPadButtonStyle())
                    .disabled(price == 0 || (requiresCategory && category == nil))
                }
            }
            .frame(width: proxy.size.width, height: proxy.size.height)
        }
        .padding(.bottom, 15)
    }

    private func button(_ number: Int, size: CGSize) -> some View {
        Button {
            guard price < 100_000_000 else { return }
            UIImpactFeedbackGenerator(style: .light).impactOccurred()
            if numberEntryType == 1 {
                price *= 10
                price += Double(number) / 100
            } else {
                price *= 10
                price += Double(number)
            }
        } label: {
            Text("\(number)")
                .font(.system(size: 34, weight: .regular, design: .rounded))
                .frame(width: size.width * 0.3, height: size.height * 0.22)
                .background(Color.SecondaryBackground)
                .foregroundColor(Color.PrimaryText)
                .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))
        }
        .buttonStyle(DimeNumberPadButtonStyle())
    }

    private func deleteLastDigit() {
        price = numberEntryType == 1 ? Double(Int(price * 10)) / 100 : Double(Int(price / 10))
        isEditingDecimal = false
        decimalValuesAssigned = .none
    }
}

private struct DimeNumberPadButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? 0.93 : 1)
            .animation(.easeOut(duration: 0.15), value: configuration.isPressed)
    }
}
