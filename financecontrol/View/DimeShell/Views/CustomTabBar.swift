//
//  CustomTabBar.swift
//  Squirrel
//
//  Directly adapted from app/dime/Views/CustomTabBar.swift (Dime).
//  Destination presentation and transaction entry stay outside this visual component.
//

import SwiftUI

struct DimeCustomTabBar: View {
    @Environment(\.layoutDirection) private var layoutDirection
    @Binding var selection: DimeTabDestination
    let bottomEdge: CGFloat
    let shouldPulseAddButton: Bool
    let availableDestinations: Set<DimeTabDestination>
    let addTransaction: () -> Void

    private var destinations: [DimeTabDestination] {
        layoutDirection == .rightToLeft ? Array(DimeTabDestination.allCases.reversed()) : DimeTabDestination.allCases
    }

    var body: some View {
        HStack(spacing: 4) {
            DimeTabButton(destination: destinations[0], isAvailable: availableDestinations.contains(destinations[0]), selection: $selection)
            DimeTabButton(destination: destinations[1], isAvailable: availableDestinations.contains(destinations[1]), selection: $selection)
            DimeAddTransactionButton(shouldPulse: shouldPulseAddButton, action: addTransaction)
            DimeTabButton(destination: destinations[2], isAvailable: availableDestinations.contains(destinations[2]), selection: $selection)
            DimeTabButton(destination: destinations[3], isAvailable: availableDestinations.contains(destinations[3]), selection: $selection)
        }
        .padding(.horizontal, 15)
        .padding(.bottom, bottomEdge - 10)
        .frame(maxWidth: .infinity)
        .background(Color.PrimaryBackground)
    }
}
