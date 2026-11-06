//
//  HomeView.swift
//  Squirrel
//
//  Directly adapted from app/dime/Views/HomeView.swift (Dime).
//  This shell is registered but intentionally not activated by ContentView.
//

import SwiftUI

struct DimeHomeView: View {
    @EnvironmentObject private var coreDataModel: CoreDataModel
    @StateObject private var navigation = DimeHomeNavigationState()
    @Binding var presentOnboarding: Bool
    @Binding var statsScrollToTop: Int?
    @Binding var settingsScrollToTop: Int?
    let topEdge: CGFloat
    let bottomEdge: CGFloat
    let addTransaction: () -> Void

    init(
        presentOnboarding: Binding<Bool>,
        statsScrollToTop: Binding<Int?>,
        settingsScrollToTop: Binding<Int?>,
        topEdge: CGFloat,
        bottomEdge: CGFloat,
        addTransaction: @escaping () -> Void
    ) {
        UITabBar.appearance().isHidden = true
        _presentOnboarding = presentOnboarding
        _statsScrollToTop = statsScrollToTop
        _settingsScrollToTop = settingsScrollToTop
        self.topEdge = topEdge
        self.bottomEdge = bottomEdge
        self.addTransaction = addTransaction
    }

    var body: some View {
        ZStack(alignment: .bottom) {
            TabView(selection: $navigation.selectedDestination) {
                DimeHomeDestinationView(
                    destination: .log,
                    topEdge: topEdge,
                    bottomEdge: bottomEdge,
                    presentOnboarding: $presentOnboarding,
                    statsScrollToTop: $statsScrollToTop,
                    settingsScrollToTop: $settingsScrollToTop
                )
                .ignoresSafeArea(.all)
                .tag(DimeTabDestination.log)

                DimeHomeDestinationView(
                    destination: .insights,
                    topEdge: topEdge,
                    bottomEdge: bottomEdge,
                    presentOnboarding: $presentOnboarding,
                    statsScrollToTop: $statsScrollToTop,
                    settingsScrollToTop: $settingsScrollToTop
                )
                .tag(DimeTabDestination.insights)

                DimeHomeDestinationView(
                    destination: .settings,
                    topEdge: topEdge,
                    bottomEdge: bottomEdge,
                    presentOnboarding: $presentOnboarding,
                    statsScrollToTop: $statsScrollToTop,
                    settingsScrollToTop: $settingsScrollToTop
                )
                .tag(DimeTabDestination.settings)
            }

            DimeCustomTabBar(
                selection: Binding(
                    get: { navigation.selectedDestination },
                    set: { navigation.select($0) }
                ),
                bottomEdge: bottomEdge,
                shouldPulseAddButton: coreDataModel.savedSpendings.isEmpty,
                availableDestinations: navigation.availableDestinations,
                addTransaction: addTransaction
            )
        }
    }
}
