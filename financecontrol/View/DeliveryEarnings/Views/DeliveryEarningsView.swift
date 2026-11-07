//
//  DeliveryEarningsView.swift
//  Squirrel
//

import SwiftUI

struct DeliveryEarningsView: View {
    let bottomEdge: CGFloat
    @Binding var isInputFocused: Bool
    @StateObject private var viewModel = DeliveryEarningsViewModel()
    @FocusState private var focusedField: DeliveryEarningsField?

    var body: some View {
        ScrollViewReader { proxy in
            ScrollView {
                VStack(alignment: .leading, spacing: 12) {
                    header
                    ratesSection
                    workSection
                    resultSection
                    clearButton
                }
                .padding(.horizontal, 14)
                .padding(.top, 18)
                .padding(.bottom, focusedField == nil ? max(bottomEdge + 82, 104) : 0)
            }
            .scrollDismissesKeyboardCompat()
            .onChange(of: focusedField) { field in
                isInputFocused = field != nil
                guard let field else { return }
                withAnimation(.easeInOut(duration: 0.2)) {
                    proxy.scrollTo(field, anchor: .center)
                }
            }
        }
        .toolbar {
            ToolbarItemGroup(placement: .keyboard) {
                Spacer()
                Button("إخفاء لوحة المفاتيح", systemImage: "keyboard.chevron.compact.down") {
                    focusedField = nil
                }
            }
        }
        .environment(\.layoutDirection, .rightToLeft)
        .background(Color(uiColor: .systemGroupedBackground).ignoresSafeArea())
        .onDisappear { isInputFocused = false }
        .onReceive(NotificationCenter.default.publisher(for: UIResponder.keyboardWillHideNotification)) { _ in
            focusedField = nil
        }
    }

    private var header: some View {
        VStack(alignment: .leading, spacing: 3) {
            Text("حاسبة العمل")
                .font(.footnote.weight(.bold))
                .foregroundStyle(DeliveryEarningsStyle.accent)
            Text("أرباح التوصيل")
                .font(.system(.largeTitle, design: .rounded).weight(.bold))
                .accessibilityAddTraits(.isHeader)
            Text("احسب أرباح التوصيل والكاش والمصروفات بسهولة.")
                .font(.footnote)
                .foregroundStyle(.secondary)
        }
        .padding(.horizontal, 2)
    }

    private var ratesSection: some View {
        VStack(alignment: .leading, spacing: 13) {
            sectionTitle("أسعار الحساب", hint: "تُحفظ تلقائيًا")
            HStack(alignment: .top, spacing: 9) {
                DeliveryEarningsInput(
                    title: "سعر الطلب الواحد (€)", symbol: nil, unit: "€", keyboardType: .decimalPad,
                    field: .orderRate, text: $viewModel.orderRateText, focusedField: $focusedField
                )
                .id(DeliveryEarningsField.orderRate)
                DeliveryEarningsInput(
                    title: "سعر الكيلومتر (€)", symbol: nil, unit: "€", keyboardType: .decimalPad,
                    field: .kilometerRate, text: $viewModel.kilometerRateText, focusedField: $focusedField
                )
                .id(DeliveryEarningsField.kilometerRate)
            }
            Text("تبقى الأسعار محفوظة حتى تقوم بتغييرها.")
                .font(.caption2)
                .foregroundStyle(.secondary)
        }
        .padding(15)
        .deliveryEarningsGlassSurface()
    }

    private var workSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            sectionTitle("تفاصيل العمل", hint: "أدخل أرقامك")
            HStack(alignment: .top, spacing: 9) {
                DeliveryEarningsWorkCard(
                    title: "عدد الطلبات", symbol: "shippingbox.fill", unit: nil, keyboardType: .numberPad,
                    field: .orders, text: $viewModel.ordersText, focusedField: $focusedField
                )
                .id(DeliveryEarningsField.orders)
                DeliveryEarningsWorkCard(
                    title: "الكيلومترات", symbol: "bicycle", unit: nil, keyboardType: .decimalPad,
                    field: .kilometers, text: $viewModel.kilometersText, focusedField: $focusedField
                )
                .id(DeliveryEarningsField.kilometers)
            }

            HStack(spacing: 12) {
                VStack(alignment: .leading, spacing: 3) {
                    Label("الإكراميات", systemImage: "eurosign.circle.fill")
                        .font(.footnote.weight(.semibold))
                    Text("إجمالي الإكراميات")
                        .font(.caption2)
                        .foregroundStyle(.secondary)
                }
                DeliveryEarningsInput(
                    title: "", symbol: nil, unit: "€", keyboardType: .decimalPad,
                    field: .tips, text: $viewModel.tipsText, focusedField: $focusedField
                )
                .frame(maxWidth: 150)
                .id(DeliveryEarningsField.tips)
            }
            .padding(11)
            .background(DeliveryEarningsStyle.workCardBackground, in: RoundedRectangle(cornerRadius: 15, style: .continuous))

            Text("الكاش والمصروفات")
                .font(.caption.weight(.semibold))
                .foregroundStyle(.secondary)
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.top, 2)
                .overlay(alignment: .top) { Divider() }

            HStack(alignment: .top, spacing: 9) {
                DeliveryEarningsWorkCard(
                    title: "استلام كاش", symbol: "banknote.fill", unit: "€", keyboardType: .decimalPad,
                    field: .cashReceived, text: $viewModel.cashReceivedText, focusedField: $focusedField
                )
                .id(DeliveryEarningsField.cashReceived)
                DeliveryEarningsWorkCard(
                    title: "مصروف من الكاش", symbol: "minus.circle.fill", unit: "€", keyboardType: .decimalPad,
                    field: .cashExpense, text: $viewModel.cashExpenseText, focusedField: $focusedField
                )
                .id(DeliveryEarningsField.cashExpense)
            }
        }
        .padding(15)
        .deliveryEarningsGlassSurface()
    }

    @ViewBuilder
    private var resultSection: some View {
        switch viewModel.calculation {
        case let .result(result):
            DeliveryEarningsResultCard(result: result)
        case .empty:
            DeliveryEarningsResultCard(result: nil)
        case let .validationError(message):
            DeliveryEarningsResultCard(result: nil, message: message)
        }
    }

    private var clearButton: some View {
        Button {
            withAnimation(.easeInOut(duration: 0.2)) {
                viewModel.clearWorkInputs()
                focusedField = nil
            }
        } label: {
            Label("تفريغ الحقول", systemImage: "trash")
                .font(.body.weight(.semibold))
                .frame(maxWidth: .infinity, minHeight: 46)
        }
        .buttonStyle(.plain)
        .foregroundStyle(.primary)
        .deliveryEarningsGlassSurface(cornerRadius: 14)
        .accessibilityHint("لا يحذف أسعار الطلب والكيلومتر المحفوظة")
    }

    private func sectionTitle(_ title: String, hint: String) -> some View {
        HStack(alignment: .firstTextBaseline) {
            Text(title)
                .font(.headline.weight(.bold))
            Spacer(minLength: 8)
            Text(hint)
                .font(.caption)
                .foregroundStyle(.secondary)
        }
    }
}

private struct DeliveryEarningsResultCard: View {
    let result: DeliveryEarningsResult?
    var message: String? = nil

    var body: some View {
        VStack(alignment: .leading, spacing: 9) {
            Text("صافي المستحقات")
                .font(.subheadline.weight(.semibold))
                .foregroundStyle(.white.opacity(0.9))
            Text(result.map { DeliveryEarningsCalculator.currency($0.netPayable) } ?? "—")
                .font(.system(size: 34, weight: .bold, design: .rounded))
                .contentTransitionNumericText()
                .frame(maxWidth: .infinity, alignment: .trailing)
                .environment(\.layoutDirection, .leftToRight)
                .accessibilityLabel("صافي المستحقات")
            Divider().overlay(.white.opacity(0.3))
            resultRow("إجمالي الأرباح", value: result.map { DeliveryEarningsCalculator.currency($0.gross) } ?? "—")
            resultRow("استلام كاش", value: result.map { DeliveryEarningsCalculator.currency(-$0.cashReceived) } ?? "—")
            resultRow("مصروف من الكاش", value: result.map { DeliveryEarningsCalculator.currency(-$0.cashExpense) } ?? "—")
            if let message {
                Text(message)
                    .font(.caption2)
                    .foregroundStyle(.white.opacity(0.9))
            }
        }
        .padding(17)
        .foregroundStyle(.white)
        .background(
            LinearGradient(
                colors: [Color(red: 0.02, green: 0.43, blue: 0.48), DeliveryEarningsStyle.accent],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            ),
            in: RoundedRectangle(cornerRadius: 20, style: .continuous)
        )
        .animation(.easeInOut(duration: 0.2), value: result)
    }

    private func resultRow(_ label: String, value: String) -> some View {
        HStack {
            Text(label)
            Spacer(minLength: 8)
            Text(value)
                .fontWeight(.semibold)
                .environment(\.layoutDirection, .leftToRight)
        }
        .font(.caption)
    }
}

private extension View {
    @ViewBuilder
    func scrollDismissesKeyboardCompat() -> some View {
        if #available(iOS 16.0, *) {
            scrollDismissesKeyboard(.interactively)
        } else {
            self
        }
    }
}
