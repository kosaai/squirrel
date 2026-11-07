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

    func testLeadingCommaDecimalCalculatesExpectedEarnings() {
        let calculation = DeliveryEarningsCalculator.calculation(
            ordersText: "30",
            kilometersText: "25",
            tipsText: "50",
            orderRateText: "3",
            kilometerRateText: ",75",
            cashReceivedText: "50",
            cashExpenseText: ""
        )

        guard case let .result(result) = calculation else {
            return XCTFail("Expected a result for a leading comma decimal")
        }

        XCTAssertEqual(result.gross, Decimal(string: "158.75"))
        XCTAssertEqual(result.netPayable, Decimal(string: "108.75"))
    }

    func testEquivalentLatinArabicAndPersianDecimalInputsCalculateCorrectly() {
        for kilometerRate in ["0,75", ",75", "0.75", ".75", "٠٫٧٥", "۰٫۷۵"] {
            let calculation = DeliveryEarningsCalculator.calculation(
                ordersText: "3",
                kilometersText: "4",
                tipsText: "0",
                orderRateText: "2.5",
                kilometerRateText: kilometerRate,
                cashReceivedText: "0",
                cashExpenseText: "0"
            )

            guard case let .result(result) = calculation else {
                return XCTFail("Expected \(kilometerRate) to parse as 0.75")
            }

            XCTAssertEqual(result.gross, Decimal(string: "10.5"))
        }
    }

    func testArabicWholeNumberIsNotInterpretedAsDecimal() {
        let calculation = DeliveryEarningsCalculator.calculation(
            ordersText: "٧٥",
            kilometersText: "0",
            tipsText: "0",
            orderRateText: "1",
            kilometerRateText: "0",
            cashReceivedText: "0",
            cashExpenseText: "0"
        )

        guard case let .result(result) = calculation else {
            return XCTFail("Expected Arabic whole-number input to calculate")
        }

        XCTAssertEqual(result.gross, Decimal(string: "75"))
        XCTAssertEqual(result.netPayable, Decimal(string: "75"))
    }

    func testEmptyOptionalFieldsAreZeroAndTrailingDecimalDoesNotValidateAsInvalid() {
        let calculation = DeliveryEarningsCalculator.calculation(
            ordersText: "1",
            kilometersText: "1",
            tipsText: "",
            orderRateText: "3",
            kilometerRateText: "0,",
            cashReceivedText: "",
            cashExpenseText: ""
        )

        guard case let .result(result) = calculation else {
            return XCTFail("Expected empty optional fields and a trailing decimal separator to remain valid")
        }

        XCTAssertEqual(result.gross, Decimal(string: "3"))
        XCTAssertEqual(result.netPayable, Decimal(string: "3"))
    }

    func testInvalidAndNegativeAmountsReturnValidationErrors() {
        for kilometerRate in ["not-a-number", "-0.75"] {
            let calculation = DeliveryEarningsCalculator.calculation(
                ordersText: "1",
                kilometersText: "1",
                tipsText: "0",
                orderRateText: "3",
                kilometerRateText: kilometerRate,
                cashReceivedText: "0",
                cashExpenseText: "0"
            )

            guard case .validationError = calculation else {
                return XCTFail("Expected \(kilometerRate) to be rejected")
            }
        }
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

    func testChangingRateRecalculatesImmediatelyAndSurvivesNewViewModel() {
        let suiteName = "DeliveryEarningsCalculatorRatePersistenceTests"
        let defaults = UserDefaults(suiteName: suiteName)!
        defaults.removePersistentDomain(forName: suiteName)
        defer { defaults.removePersistentDomain(forName: suiteName) }

        let viewModel = DeliveryEarningsViewModel(defaults: defaults)
        viewModel.ordersText = "2"
        viewModel.kilometersText = "0"
        viewModel.orderRateText = "3"
        viewModel.kilometerRateText = ",75"

        guard case let .result(initialResult) = viewModel.calculation else {
            return XCTFail("Expected an initial calculation result")
        }
        XCTAssertEqual(initialResult.gross, Decimal(string: "6"))

        viewModel.orderRateText = "4"

        guard case let .result(updatedResult) = viewModel.calculation else {
            return XCTFail("Expected a recalculated result after changing the order rate")
        }
        XCTAssertEqual(updatedResult.gross, Decimal(string: "8"))

        let restoredViewModel = DeliveryEarningsViewModel(defaults: defaults)
        XCTAssertEqual(restoredViewModel.orderRateText, "4")
        XCTAssertEqual(restoredViewModel.kilometerRateText, ",75")
    }
}
