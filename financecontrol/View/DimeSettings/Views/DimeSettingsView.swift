// Faithful local migration of Dime's original SettingsView grouping and rows.
import SwiftUI
import UserNotifications

struct DimeSettingsView: View {
    @EnvironmentObject private var coreDataModel: CoreDataModel
    @AppStorage(UDKey.autoDarkMode.rawValue) private var autoDarkMode = true
    @AppStorage(UDKey.darkMode.rawValue) private var darkMode = false
    @AppStorage(UDKey.privacyScreen.rawValue) private var privacyScreen = false
    @AppStorage("dimeShowNotifications") private var notificationsEnabled = false
    @State private var destination: DimeSettingsDestination?
    @State private var presentOnboarding = false
    @StateObject private var privacyMonitor = PrivacyMonitor(privacyScreenIsEnabled: false, hideExpenseSum: false)

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
                    destinationRow(.notifications, icon: "bell.fill", title: "Dime Settings Notifications", color: Color(hex: "#61C7FA"), detail: notificationsEnabled ? String(localized: "Dime Settings On") : String(localized: "Dime Settings Off"))
                    destinationRow(.numberEntry, icon: "keyboard.fill", title: "Dime Settings Number Entry", color: Color(hex: "#F3BF56"), detail: numberEntrySummary)
                    destinationRow(.formatting, icon: "calendar", title: "Dime Settings Time Frames", color: Color(hex: "#F6D24A"))
                    DimeSettingsToggleRow(icon: "eye.slash.fill", title: "Dime Settings Hide App Content", color: Color(hex: "#7014F5"), isOn: $privacyScreen)
                }

                DimeSettingsSection(title: "Dime Settings Appearance") {
                    destinationRow(.appearance, icon: "circle.righthalf.filled", title: "Dime Settings Theme", color: Color(hex: "#279AF4"), detail: themeSummary)
                }

                DimeSettingsSection(title: "Dime Settings Data") {
                    destinationRow(.categories, icon: "rectangle.grid.2x2.fill", title: "Dime Settings Categories", color: Color(hex: "#EB7068"))
                    destinationRow(.data, icon: "externaldrive.fill", title: "Dime Settings Local Data", color: Color(hex: "#84B4EB"), detail: String(localized: "Dime Settings Local Only"))
                }

                DimeSettingsSection(title: "Dime Settings Other") {
                    destinationRow(.about, icon: "info.circle.fill", title: "Dime Settings About", color: Color(hex: "#F1AF8A"))
                }

                Text("Dime Settings EUR Local Footer")
                    .font(.system(.footnote, design: .rounded).weight(.medium))
                    .foregroundColor(Color.SubtitleText)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 25)
                    .padding(.bottom, 95)
            }
        }
        .background(Color.PrimaryBackground)
        .fullScreenCover(item: $destination) { destination in
            destinationView(destination)
                .environmentObject(coreDataModel)
        }
    }

    private var themeSummary: String {
        if autoDarkMode { return String(localized: "Dime Settings System") }
        return darkMode ? String(localized: "Dime Settings Dark") : String(localized: "Dime Settings Light")
    }

    @AppStorage("dimeNumberEntryType") private var numberEntryType = 1

    private var numberEntrySummary: String {
        String(localized: numberEntryType == 1 ? "Dime Settings Number Entry Type One" : "Dime Settings Number Entry Type Two")
    }

    private func destinationRow(_ destination: DimeSettingsDestination, icon: String, title: LocalizedStringKey, color: Color, detail: String? = nil) -> some View {
        Button { self.destination = destination } label: {
            DimeSettingsRow(icon: icon, title: title, color: color, detail: detail)
        }
        .buttonStyle(.plain)
    }

    @ViewBuilder
    private func destinationView(_ destination: DimeSettingsDestination) -> some View {
        switch destination {
        case .categories:
            DimeCategoriesSettingsAdapter()
        case .appearance:
            DimeAppearanceSettings()
        case .numberEntry:
            DimeNumberEntrySettings()
        case .notifications:
            DimeNotificationSettings()
        case .formatting:
            DimeSettingsNavigationContainer(title: "Dime Settings Time Frames") {
                SettingsFormattingView()
            }
        case .data:
            DimeSettingsNavigationContainer(title: "Dime Settings Local Data") {
                ExportAndBackupView()
                    .environmentObject(privacyMonitor)
            }
        case .about:
            DimeSettingsNavigationContainer(title: "Dime Settings About") {
                AboutView(presentOnboarding: $presentOnboarding)
            }
        }
    }
}

private enum DimeSettingsDestination: Hashable, Identifiable {
    case categories, appearance, notifications, numberEntry, formatting, data, about
    var id: Self { self }
}

/// Categories are presented directly in their one navigation container. This
/// deliberately bypasses Squirrel's SettingsView to prevent nested Settings.
private struct DimeCategoriesSettingsAdapter: View {
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationView {
            CategoriesEditView()
                .toolbar {
                    ToolbarItem(placement: .cancellationAction) {
                        Button("Dime Settings Close") { dismiss() }
                    }
                }
        }
        .navigationViewStyle(.stack)
    }
}

private struct DimeSettingsNavigationContainer<Content: View>: View {
    @Environment(\.dismiss) private var dismiss
    let title: LocalizedStringKey
    @ViewBuilder let content: Content

    var body: some View {
        NavigationView {
            content
                .navigationTitle(title)
                .navigationBarTitleDisplayMode(.inline)
                .toolbar {
                    ToolbarItem(placement: .cancellationAction) {
                        Button("Dime Settings Close") { dismiss() }
                    }
                }
        }
        .navigationViewStyle(.stack)
    }
}

/// Migrated from Dime's SettingsAppearanceView, backed by Squirrel's existing
/// theme preferences rather than a separate Dime-only color-scheme store.
private struct DimeAppearanceSettings: View {
    @Environment(\.dismiss) private var dismiss
    @AppStorage(UDKey.autoDarkMode.rawValue) private var automatic = true
    @AppStorage(UDKey.darkMode.rawValue) private var darkMode = false

    var body: some View {
        DimeSettingsSubpage(title: "Dime Settings Theme") {
            VStack(spacing: 0) {
                choice("Dime Settings System", isSelected: automatic) {
                    automatic = true
                    UIApplication.shared.keyWindow?.overrideUserInterfaceStyle = .unspecified
                }
                Divider()
                choice("Dime Settings Light", isSelected: !automatic && !darkMode) {
                    automatic = false
                    darkMode = false
                    UIApplication.shared.keyWindow?.overrideUserInterfaceStyle = .light
                }
                Divider()
                choice("Dime Settings Dark", isSelected: !automatic && darkMode) {
                    automatic = false
                    darkMode = true
                    UIApplication.shared.keyWindow?.overrideUserInterfaceStyle = .dark
                }
            }
            .padding(.horizontal, 15)
            .background(Color.SettingsBackground, in: RoundedRectangle(cornerRadius: 9, style: .continuous))

            Text("Dime Settings Theme Description")
                .font(.system(.caption, design: .rounded).weight(.medium))
                .foregroundColor(Color.SubtitleText)
                .padding(.horizontal, 15)
                .frame(maxWidth: .infinity, alignment: .leading)
        }
    }

    private func choice(_ title: LocalizedStringKey, isSelected: Bool, action: @escaping () -> Void) -> some View {
        Button {
            withAnimation(.easeIn(duration: 0.15), action)
        } label: {
            HStack {
                Text(title).foregroundColor(Color.PrimaryText)
                Spacer()
                if isSelected { Image(systemName: "checkmark").foregroundColor(Color.DarkIcon.opacity(0.6)) }
            }
            .padding(.vertical, 9)
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
    }
}

/// Migrated from Dime's SettingsNumberEntryView; both modes are consumed by
/// DimeNumberPad, so this preference changes actual transaction entry.
private struct DimeNumberEntrySettings: View {
    @AppStorage("dimeNumberEntryType") private var numberEntryType = 1

    var body: some View {
        DimeSettingsSubpage(title: "Dime Settings Number Entry") {
            VStack(spacing: 0) {
                option("Dime Settings Number Entry Type One", detail: "Dime Settings Number Entry Type One Description", value: 1)
                Divider()
                option("Dime Settings Number Entry Type Two", detail: "Dime Settings Number Entry Type Two Description", value: 2)
            }
            .padding(.horizontal, 15)
            .background(Color.SettingsBackground, in: RoundedRectangle(cornerRadius: 9, style: .continuous))
        }
    }

    private func option(_ title: LocalizedStringKey, detail: LocalizedStringKey, value: Int) -> some View {
        Button {
            withAnimation(.easeIn(duration: 0.15)) { numberEntryType = value }
        } label: {
            HStack {
                VStack(alignment: .leading, spacing: 3) {
                    Text(title).foregroundColor(Color.PrimaryText)
                    Text(detail).font(.caption).foregroundColor(Color.SubtitleText)
                }
                Spacer()
                if numberEntryType == value { Image(systemName: "checkmark").foregroundColor(Color.DarkIcon.opacity(0.6)) }
            }
            .padding(.vertical, 9)
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
    }
}

/// Migrated from Dime's SettingsNotificationsView. It schedules only local
/// reminders and does not introduce a remote or cloud notification service.
private struct DimeNotificationSettings: View {
    @Environment(\.dismiss) private var dismiss
    @AppStorage("dimeShowNotifications") private var enabled = false
    @AppStorage("dimeNotificationHour") private var hour = 8
    @AppStorage("dimeNotificationMinute") private var minute = 0
    @State private var authorizationDenied = false

    private var reminderTime: Binding<Date> {
        Binding {
            Calendar.current.date(from: DateComponents(hour: hour, minute: minute)) ?? .now
        } set: { date in
            let components = Calendar.current.dateComponents([.hour, .minute], from: date)
            hour = components.hour ?? 8
            minute = components.minute ?? 0
            scheduleReminder()
        }
    }

    var body: some View {
        DimeSettingsSubpage(title: "Dime Settings Notifications") {
            VStack(spacing: 0) {
                Toggle("Dime Settings Enable Notifications", isOn: $enabled)
                    .tint(.green)
                    .padding(.vertical, 9)
                    .onChange(of: enabled) { value in
                        value ? requestAndScheduleReminder() : removeReminder()
                    }

                if enabled {
                    Divider()
                    DatePicker("Dime Settings Reminder Time", selection: reminderTime, displayedComponents: .hourAndMinute)
                        .padding(.vertical, 9)
                }
            }
            .padding(.horizontal, 15)
            .background(Color.SettingsBackground, in: RoundedRectangle(cornerRadius: 9, style: .continuous))

            Text("Dime Settings Notification Description")
                .font(.system(.caption, design: .rounded).weight(.medium))
                .foregroundColor(Color.SubtitleText)
                .padding(.horizontal, 15)
                .frame(maxWidth: .infinity, alignment: .leading)
        }
        .alert("Dime Settings Notifications Unavailable", isPresented: $authorizationDenied) {
            Button("Dime Settings Close", role: .cancel) {}
        } message: {
            Text("Dime Settings Notifications Unavailable Description")
        }
    }

    private func requestAndScheduleReminder() {
        UNUserNotificationCenter.current().getNotificationSettings { settings in
            switch settings.authorizationStatus {
            case .notDetermined:
                UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound]) { granted, _ in
                    DispatchQueue.main.async {
                        enabled = granted
                        granted ? scheduleReminder() : (authorizationDenied = true)
                    }
                }
            case .authorized, .provisional, .ephemeral:
                scheduleReminder()
            default:
                DispatchQueue.main.async {
                    enabled = false
                    authorizationDenied = true
                }
            }
        }
    }

    private func scheduleReminder() {
        guard enabled else { return }
        let content = UNMutableNotificationContent()
        content.title = String(localized: "Dime Settings Reminder Title")
        content.body = String(localized: "Dime Settings Reminder Body")
        content.sound = .default
        let trigger = UNCalendarNotificationTrigger(dateMatching: DateComponents(hour: hour, minute: minute), repeats: true)
        UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: ["dime.daily-reminder"])
        UNUserNotificationCenter.current().add(UNNotificationRequest(identifier: "dime.daily-reminder", content: content, trigger: trigger))
    }

    private func removeReminder() {
        UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: ["dime.daily-reminder"])
    }
}

private struct DimeSettingsSubpage<Content: View>: View {
    @Environment(\.dismiss) private var dismiss
    let title: LocalizedStringKey
    @ViewBuilder let content: Content

    var body: some View {
        VStack(spacing: 10) {
            Text(title)
                .font(.system(.title3, design: .rounded).weight(.semibold))
                .foregroundColor(Color.PrimaryText)
                .frame(maxWidth: .infinity)
                .overlay(alignment: .leading) {
                    Button { dismiss() } label: {
                        Image(systemName: "chevron.backward")
                            .font(.system(.body, design: .rounded).weight(.semibold))
                            .foregroundColor(Color.DarkIcon)
                            .frame(width: 44, height: 44)
                    }
                    .accessibilityLabel("Dime Settings Close")
                }
                .padding(.bottom, 20)
            content
            Spacer()
        }
        .padding(.horizontal, 20)
        .padding(.top, 20)
        .background(Color.PrimaryBackground.ignoresSafeArea())
    }
}
