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
    @Environment(\.scenePhase) private var scenePhase
    @StateObject private var navigation = DimeHomeNavigationState()
    @Binding var presentOnboarding: Bool
    @Binding var statsScrollToTop: Int?
    @Binding var settingsScrollToTop: Int?
    let topEdge: CGFloat
    let bottomEdge: CGFloat
    @State private var showTransactionEditor = false

    init(
        presentOnboarding: Binding<Bool>,
        statsScrollToTop: Binding<Int?>,
        settingsScrollToTop: Binding<Int?>,
        topEdge: CGFloat,
        bottomEdge: CGFloat
    ) {
        UITabBar.appearance().isHidden = true
        _presentOnboarding = presentOnboarding
        _statsScrollToTop = statsScrollToTop
        _settingsScrollToTop = settingsScrollToTop
        self.topEdge = topEdge
        self.bottomEdge = bottomEdge
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

                DimeHomeDestinationView(destination: .budget, topEdge: topEdge, bottomEdge: bottomEdge, presentOnboarding: $presentOnboarding, statsScrollToTop: $statsScrollToTop, settingsScrollToTop: $settingsScrollToTop)
                .tag(DimeTabDestination.budget)

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
                addTransaction: { showTransactionEditor = true }
            )
        }
        .sheet(isPresented: $showTransactionEditor) {
            DimeTransactionView()
                .environmentObject(coreDataModel)
        }
        .onAppear { coreDataModel.generateDueScheduledTransactions() }
        .onChange(of: scenePhase) { phase in
            if phase == .active {
                coreDataModel.generateDueScheduledTransactions()
            }
        }
    }
}
