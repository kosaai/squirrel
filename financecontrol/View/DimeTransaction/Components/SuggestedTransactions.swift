//
//  SuggestedTransactions.swift
//  Squirrel
//
//  Directly adapted from Dime Components/Transactions/SuggestedTransactions.swift.
//

import SwiftUI

struct DimeSuggestedTransactions: View {
    @Binding var note: String
    @Binding var amount: Double
    @Binding var category: CategoryEntity?
    let suggestions: [SpendingEntity]

    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 8) {
                ForEach(suggestions) { spending in
                    Button {
                        withAnimation {
                            note = spending.comment ?? ""
                            amount = spending.amount
                            if category == nil { category = spending.category }
                        }
                        hideKeyboard()
                    } label: {
                        HStack(spacing: 3) {
                            Text(spending.comment ?? "")
                                .font(.system(.body, design: .rounded).weight(.semibold))
                                .foregroundStyle(Color.PrimaryText)
                                .lineLimit(1)
                                .padding(.vertical, 3.5)
                                .padding(.horizontal, 7)
                            Text(spending.amount, format: .currency(code: "EUR"))
                                .font(.system(.body, design: .rounded).weight(.semibold))
                                .lineLimit(1)
                                .foregroundStyle(Color(hex: spending.category?.color ?? "#FFFFFF"))
                                .padding(.vertical, 3.5)
                                .padding(.horizontal, 5)
                                .background(Color(hex: spending.category?.color ?? "#FFFFFF").opacity(0.23), in: RoundedRectangle(cornerRadius: 6.5, style: .continuous))
                        }
                        .padding(5)
                        .background(Color.SecondaryBackground, in: RoundedRectangle(cornerRadius: 11.5, style: .continuous))
                    }
                }
            }
        }
        .padding(.bottom, 5)
    }
}
