//
//  TransactionCategoryPicker.swift
//  Squirrel
//
//  Directly adapted from Dime Components/Transactions/TransactionCategoryPicker.swift.
//

import SwiftUI

struct DimeTransactionCategoryPicker: View {
    @Binding var category: CategoryEntity?
    @Binding var showPicker: Bool
    let categories: [CategoryEntity]

    private let layout = [GridItem(.flexible(), spacing: 10), GridItem(.flexible())]

    var body: some View {
        ScrollView(showsIndicators: false) {
            LazyVGrid(columns: layout, spacing: 10) {
                ForEach(categories) { item in
                    HStack(spacing: 7) {
                        Text(item.name.map { String($0.prefix(1)) } ?? "")
                            .font(.system(.subheadline, design: .rounded))
                        Text(item.name ?? "")
                            .font(.system(.body, design: .rounded).weight(.semibold))
                            .lineLimit(1)
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.horizontal, 11)
                    .padding(.vertical, 9)
                    .foregroundColor(Color(hex: item.color ?? "#FFFFFF"))
                    .background(Color(hex: item.color ?? "#FFFFFF").opacity(0.35), in: RoundedRectangle(cornerRadius: 11.5, style: .continuous))
                    .contentShape(Rectangle())
                    .overlay {
                        if item.id == category?.id {
                            RoundedRectangle(cornerRadius: 11.5, style: .continuous)
                                .strokeBorder(Color(hex: item.color ?? "#FFFFFF"), lineWidth: 2)
                        }
                    }
                    .onTapGesture {
                        withAnimation { category = item }
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                            withAnimation { showPicker = false }
                        }
                    }
                    .opacity(category == nil || item.id == category?.id ? 1 : 0.5)
                }
            }
        }
        .dynamicTypeSize(...DynamicTypeSize.xxxLarge)
        .padding()
        .background(Color.PrimaryBackground)
    }
}
