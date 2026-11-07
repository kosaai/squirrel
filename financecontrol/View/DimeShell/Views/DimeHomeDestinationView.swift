//
//  DimeHomeDestinationView.swift
//  Squirrel
//
//  Destination composition adapted from Dime HomeView's TabView.
//

import SwiftUI

struct DimeHomeDestinationView: View {
    let destination: DimeTabDestination
    let topEdge: CGFloat
    let bottomEdge: CGFloat
    @Binding var presentOnboarding: Bool
    @Binding var statsScrollToTop: Int?
    @Binding var settingsScrollToTop: Int?
    @Binding var isDeliveryEarningsInputFocused: Bool

    var body: some View {
        Group {
            if destination == .log {
                DimeLogView(topEdge: topEdge, bottomEdge: bottomEdge)
            } else if destination == .insights {
                DimeInsightsView()
            } else if destination == .budget {
                DeliveryEarningsView(
                    bottomEdge: bottomEdge,
                    isInputFocused: $isDeliveryEarningsInputFocused
                )
            } else {
                DimeSettingsView()
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}
