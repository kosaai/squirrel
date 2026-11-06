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

    var body: some View {
        Group {
            if destination == .log {
                DimeLogView(topEdge: topEdge, bottomEdge: bottomEdge)
            } else if destination == .insights {
                StatsView(scrollToTop: $statsScrollToTop)
            } else if destination == .budget {
                DimeBudgetView()
            } else {
                SettingsView(
                    showDarkModeToggle: true,
                    presentOnboarding: $presentOnboarding,
                    scrollToTop: $settingsScrollToTop
                )
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}
