//
//  DeliveryEarningsCalculatorTests.swift
//  SquirrelTests
//

import XCTest
@testable import Squirrel

@MainActor
final class DeliveryEarningsCalculatorTests: XCTestCase {
    func testExampleCalculationUsesExactDecimalCurrencyValues() {
        let calculation = DeliveryEarningsCalculator.calculation(
            ordersText: "300",
            kilometersText: "400",
            tipsText: "500",
            orderRateText: "3",
            kilometerRateText: "0.75",
            cashReceivedText: "500",
            cashExpenseText: "300"
        )

        guard case let .result(result) = calculation else {
            return XCTFail("Expected a delivery earnings result")
        }

        XCTAssertEqual(result.gross, Decimal(string: "1700"))
        XCTAssertEqual(result.netPayable, Decimal(string: "900"))
    }

    func testArabicAndGermanDecimalSeparatorsCalculateCorrectly() {
        let calculation = DeliveryEarningsCalculator.calculation(
            ordersText: "٣",
            kilometersText: "٤",
            tipsText: "١,٥",
            orderRateText: "٢٫٥",
            kilometerRateText: "0,75",
            cashReceivedText: "0",
            cashExpenseText: "0"
        )

        guard case let .result(result) = calculation else {
            return XCTFail("Expected Arabic and German decimal input to parse")
        }

        XCTAssertEqual(result.gross, Decimal(string: "12"))
        XCTAssertEqual(result.netPayable, Decimal(string: "12"))
    }

    func testClearingWorkInputsKeepsPersistedRates() {
        let suiteName = "DeliveryEarningsCalculatorTests"
        let defaults = UserDefaults(suiteName: suiteName)!
        defaults.removePersistentDomain(forName: suiteName)
        defer { defaults.removePersistentDomain(forName: suiteName) }

        let viewModel = DeliveryEarningsViewModel(defaults: defaults)
        viewModel.orderRateText = "3"
        viewModel.kilometerRateText = "0,75"
        viewModel.ordersText = "300"
        viewModel.kilometersText = "400"
        viewModel.tipsText = "500"
        viewModel.cashReceivedText = "500"
        viewModel.cashExpenseText = "300"

        viewModel.clearWorkInputs()

        XCTAssertEqual(viewModel.orderRateText, "3")
        XCTAssertEqual(viewModel.kilometerRateText, "0,75")
        XCTAssertTrue(viewModel.ordersText.isEmpty)
        XCTAssertTrue(viewModel.kilometersText.isEmpty)
        XCTAssertTrue(viewModel.tipsText.isEmpty)
        XCTAssertTrue(viewModel.cashReceivedText.isEmpty)
        XCTAssertTrue(viewModel.cashExpenseText.isEmpty)

        let restoredViewModel = DeliveryEarningsViewModel(defaults: defaults)
        XCTAssertEqual(restoredViewModel.orderRateText, "3")
        XCTAssertEqual(restoredViewModel.kilometerRateText, "0,75")
    }
}
