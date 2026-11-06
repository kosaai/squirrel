// Source-driven adaptation of Dime Views/Settings/SettingsView.swift.
import SwiftUI

struct DimeSettingsView: View {
    @State private var presentOnboarding = false
    @State private var scrollToTop: Int?
    @State private var showSquirrelSettings = false

    var body: some View {
        VStack(spacing: 0) {
            HStack {
                Text("Dime Settings Title")
                    .font(.system(.title, design: .rounded).weight(.semibold))
                    .accessibilityAddTraits(.isHeader)
                Spacer()
            }
            .padding(.horizontal, 30)
            .padding(.top, 20)
            .padding(.bottom, 10)

            ScrollView(showsIndicators: false) {
                DimeSettingsSection(title: "Dime Settings General") {
                    settingsRow(icon: "rectangle.grid.2x2.fill", title: "Dime Settings Categories", detail: "Dime Settings Local Only")
                    settingsRow(icon: "square.and.arrow.up.fill", title: "Dime Settings Data", detail: "Dime Settings Local Only")
                }
                DimeSettingsSection(title: "Dime Settings Appearance") {
                    settingsRow(icon: "circle.righthalf.filled", title: "Dime Settings Appearance")
                }
                DimeSettingsSection(title: "Dime Settings About") {
                    settingsRow(icon: "info.circle.fill", title: "Dime Settings About")
                }
            }
            .background(Color.PrimaryBackground)
        }
        .background(Color.PrimaryBackground)
        .fullScreenCover(isPresented: $showSquirrelSettings) {
            DimeSquirrelSettingsAdapter(
                presentOnboarding: $presentOnboarding,
                scrollToTop: $scrollToTop
            )
        }
    }

    private func settingsRow(icon: String, title: LocalizedStringKey, detail: LocalizedStringKey? = nil) -> some View {
        Button { showSquirrelSettings = true } label: {
            DimeSettingsRow(icon: icon, title: title, detail: detail)
        }
        .buttonStyle(.plain)
    }
}

// Squirrel's category/data settings remain functional, but are presented outside
// DimeHomeView's ZStack so nested navigation cannot duplicate controls or expose
// Dime's tab bar over the category editor.
private struct DimeSquirrelSettingsAdapter: View {
    @Binding var presentOnboarding: Bool
    @Binding var scrollToTop: Int?
    @StateObject private var privacyMonitor = PrivacyMonitor(privacyScreenIsEnabled: false, hideExpenseSum: false)

    var body: some View {
        SettingsView(
            showDarkModeToggle: true,
            presentOnboarding: $presentOnboarding,
            scrollToTop: $scrollToTop
        )
        .environmentObject(privacyMonitor)
    }
}
