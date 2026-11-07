//
//  DeliveryEarningsViewModel.swift
//  Squirrel
//

import Foundation
import SwiftUI

struct DeliveryEarningsResult: Equatable {
    let gross: Decimal
    let cashReceived: Decimal
    let cashExpense: Decimal
    let netPayable: Decimal
}

enum DeliveryEarningsCalculationState: Equatable {
    case empty
    case result(DeliveryEarningsResult)
    case validationError(String)
}

enum DeliveryEarningsCalculator {
    static func calculation(
        ordersText: String,
        kilometersText: String,
        tipsText: String,
        orderRateText: String,
        kilometerRateText: String,
        cashReceivedText: String,
        cashExpenseText: String
    ) -> DeliveryEarningsCalculationState {
        let orders = parse(ordersText)
        let kilometers = parse(kilometersText)
        let tips = parse(tipsText)
        let orderRate = parse(orderRateText)
        let kilometerRate = parse(kilometerRateText)
        let cashReceived = parse(cashReceivedText)
        let cashExpense = parse(cashExpenseText)

        let values = [orders, kilometers, tips, orderRate, kilometerRate, cashReceived, cashExpense]
        if values.contains(where: { $0 == .invalid || $0 == .negative }) {
            return .validationError("يرجى إدخال أرقام صحيحة وغير سالبة.")
        }

        guard case let .value(orderCount) = orders,
              case let .value(kilometersValue) = kilometers,
              case let .value(tipsValue) = tips,
              case let .value(orderRateValue) = orderRate,
              case let .value(kilometerRateValue) = kilometerRate,
              case let .value(cashReceivedValue) = cashReceived,
              case let .value(cashExpenseValue) = cashExpense else {
            return .empty
        }

        if orderCount != orderCount.rounded(scale: 0) {
            return .validationError("عدد الطلبات يجب أن يكون عددًا صحيحًا.")
        }

        let hasWorkDetails = [orderCount, kilometersValue, tipsValue, cashReceivedValue, cashExpenseValue]
            .contains(where: { $0 != 0 })
        guard hasWorkDetails else { return .empty }

        if orderCount > 0, orderRateText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            return .validationError("يرجى إدخال سعر الطلب.")
        }

        if kilometersValue > 0, kilometerRateText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            return .validationError("يرجى إدخال سعر الكيلومتر.")
        }

        let gross = (orderCount * orderRateValue) + (kilometersValue * kilometerRateValue) + tipsValue
        return .result(
            DeliveryEarningsResult(
                gross: gross,
                cashReceived: cashReceivedValue,
                cashExpense: cashExpenseValue,
                netPayable: gross - cashReceivedValue - cashExpenseValue
            )
        )
    }

    static func currency(_ amount: Decimal) -> String {
        let formatter = NumberFormatter()
        formatter.locale = Locale(identifier: "de_DE")
        formatter.numberStyle = .currency
        formatter.currencyCode = "EUR"
        formatter.maximumFractionDigits = 2
        formatter.minimumFractionDigits = 2
        return formatter.string(from: NSDecimalNumber(decimal: amount)) ?? "€ 0,00"
    }

    private enum ParsedDecimal: Equatable {
        case empty
        case value(Decimal)
        case invalid
        case negative
    }

    private static func parse(_ text: String) -> ParsedDecimal {
        var normalized = normalizeDigits(text)
            .trimmingCharacters(in: .whitespacesAndNewlines)
            .replacingOccurrences(of: " ", with: "")
            .replacingOccurrences(of: "٫", with: ".")
            .replacingOccurrences(of: "٬", with: "")

        guard !normalized.isEmpty else { return .value(0) }

        if normalized.contains(","), normalized.contains(".") {
            if (normalized.lastIndex(of: ",") ?? normalized.startIndex) > (normalized.lastIndex(of: ".") ?? normalized.startIndex) {
                normalized = normalized.replacingOccurrences(of: ".", with: "").replacingOccurrences(of: ",", with: ".")
            } else {
                normalized = normalized.replacingOccurrences(of: ",", with: "")
            }
        } else {
            normalized = normalized.replacingOccurrences(of: ",", with: ".")
        }

        guard normalized.range(of: "^[+-]?\\d+(\\.\\d+)?$", options: .regularExpression) != nil,
              let decimal = Decimal(string: normalized, locale: Locale(identifier: "en_US_POSIX")) else {
            return .invalid
        }

        return decimal < 0 ? .negative : .value(decimal)
    }

    private static func normalizeDigits(_ value: String) -> String {
        let arabicDigits = Array("٠١٢٣٤٥٦٧٨٩")
        let persianDigits = Array("۰۱۲۳۴۵۶۷۸۹")
        return String(value.map { character in
            if let index = arabicDigits.firstIndex(of: character) { return Character(String(index)) }
            if let index = persianDigits.firstIndex(of: character) { return Character(String(index)) }
            return character
        })
    }
}

@MainActor
final class DeliveryEarningsViewModel: ObservableObject {
    private enum StorageKey {
        static let orderRate = "deliveryEarnings.orderRate"
        static let kilometerRate = "deliveryEarnings.kilometerRate"
    }

    private let defaults: UserDefaults
    @Published var orderRateText: String { didSet { saveRates() } }
    @Published var kilometerRateText: String { didSet { saveRates() } }
    @Published var ordersText = ""
    @Published var kilometersText = ""
    @Published var tipsText = ""
    @Published var cashReceivedText = ""
    @Published var cashExpenseText = ""

    init(defaults: UserDefaults = .standard) {
        self.defaults = defaults
        orderRateText = defaults.string(forKey: StorageKey.orderRate) ?? ""
        kilometerRateText = defaults.string(forKey: StorageKey.kilometerRate) ?? ""
    }

    var calculation: DeliveryEarningsCalculationState {
        DeliveryEarningsCalculator.calculation(
            ordersText: ordersText,
            kilometersText: kilometersText,
            tipsText: tipsText,
            orderRateText: orderRateText,
            kilometerRateText: kilometerRateText,
            cashReceivedText: cashReceivedText,
            cashExpenseText: cashExpenseText
        )
    }

    func clearWorkInputs() {
        ordersText = ""
        kilometersText = ""
        tipsText = ""
        cashReceivedText = ""
        cashExpenseText = ""
    }

    private func saveRates() {
        defaults.set(orderRateText, forKey: StorageKey.orderRate)
        defaults.set(kilometerRateText, forKey: StorageKey.kilometerRate)
    }
}

private extension Decimal {
    func rounded(scale: Int) -> Decimal {
        var value = self
        var result = Decimal()
        NSDecimalRound(&result, &value, scale, .plain)
        return result
    }
}
