//
//  DimeHomeNavigationState.swift
//  Squirrel
//
//  Navigation state adapted from Dime HomeView.swift.
//

import Combine

@MainActor
final class DimeHomeNavigationState: ObservableObject {
    @Published var selectedDestination: DimeTabDestination = .log

    let availableDestinations: Set<DimeTabDestination> = [.log, .insights, .budget, .settings]

    func select(_ destination: DimeTabDestination) {
        guard availableDestinations.contains(destination) else { return }
        selectedDestination = destination
    }
}
