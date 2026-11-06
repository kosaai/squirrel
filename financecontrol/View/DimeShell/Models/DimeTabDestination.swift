//
//  DimeTabDestination.swift
//  Squirrel
//
//  Adapted from the tab names in Dime's CustomTabBar.swift.
//

import SwiftUI

enum DimeTabDestination: String, CaseIterable, Identifiable {
    case log = "Log"
    case insights = "Insights"
    case budget = "Budget"
    case settings = "Settings"

    var id: String { rawValue }
    var imageName: String { rawValue }

    var accessibilityLabel: LocalizedStringKey {
        switch self {
        case .log: return "Dime Tab Log"
        case .insights: return "Dime Tab Insights"
        case .budget: return "Dime Tab Budget"
        case .settings: return "Dime Tab Settings"
        }
    }
}
