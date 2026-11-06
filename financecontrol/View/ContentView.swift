
//
//  ContentView.swift
//  financecontrol
//
//  Created by PinkXaciD on 2023/06/26.
//

import SwiftUI
#if DIME_QA
import Beige
#endif
#if DEBUG
import OSLog
#endif

struct ContentView: View {
    @Environment(\.scenePhase) 
    private var scenePhase
    @Environment(\.openURL)
    private var openURL
    
    @AppStorage(UDKey.presentOnboarding.rawValue)
    private var presentOnboarding: Bool = true
    @AppStorage(UDKey.color.rawValue)
    private var tint: String = "Orange"
    @AppStorage(UDKey.autoDarkMode.rawValue)
    private var autoDarkMode: Bool = true
    @AppStorage(UDKey.darkMode.rawValue)
    private var darkMode: Bool = false
    @AppStorage(UDKey.privacyScreen.rawValue)
    private var privacyScreenIsEnabled: Bool = false
    
    @StateObject
    private var cdm: CoreDataModel
    @StateObject
    private var rvm: RatesViewModel
    @StateObject
    private var filtersViewModel: FiltersViewModel
    @StateObject
    private var pieChartViewModel: PieChartViewModel
    @StateObject
    private var statsListViewModel: StatsListViewModel
    @StateObject
    private var statsSearchViewModel: StatsSearchViewModel
    @StateObject
    private var privacyMonitor: PrivacyMonitor = PrivacyMonitor(privacyScreenIsEnabled: false, hideExpenseSum: false)
    @StateObject
    private var statsViewModel: StatsViewModel = StatsViewModel()
    @StateObject
    private var barChartViewModel = BarChartViewModel(context: DataManager.shared.context)
    
    @ObservedObject 
    private var errorHandler = ErrorHandler.shared
    
    @State
    private var addExpenseAction: Bool = false
    @State
    private var hideContent: Bool = false
    
    private var selection: Binding<Int> {
        Binding(get: {
            self.selectionValue
        },
        set: {
            if $0 == selectionValue {
                // tapped twice
                self.scrollToTop = $0
                return
            }
            
            self.selectionValue = $0
        })
    }
    @State
    private var selectionValue: Int = 0
    @State
    private var scrollToTop: Int? = nil
    
    init() {
        let ratesViewModel = RatesViewModel()
        let coreDataModel = CoreDataModel(ratesViewModel: ratesViewModel)
        let filtersViewModel = FiltersViewModel()
        let pieChartViewModel = PieChartViewModel(cdm: coreDataModel, fvm: filtersViewModel)
        let statsSearchViewModel = StatsSearchViewModel()
        let statsListViewModel = StatsListViewModel(cdm: coreDataModel, fvm: filtersViewModel, pcvm: pieChartViewModel, searchModel: statsSearchViewModel)
        self._rvm = StateObject(wrappedValue: ratesViewModel)
        self._cdm = StateObject(wrappedValue: coreDataModel)
        self._pieChartViewModel = StateObject(wrappedValue: pieChartViewModel)
        self._filtersViewModel = StateObject(wrappedValue: filtersViewModel)
        self._statsListViewModel = StateObject(wrappedValue: statsListViewModel)
        self._statsSearchViewModel = StateObject(wrappedValue: statsSearchViewModel)
    }
        
    var body: some View {
#if DIME_QA
        DimeQARoot(coreDataModel: cdm, ratesViewModel: rvm)
#else
        Group {
            if #available(iOS 18.0, *) {
                NavigationStack {
                    TabView(selection: selection) {
                        homeTab
                        
                        statsTab
                        
                        settingsTab
                    }
                }
            } else {
                TabView(selection: selection) {
                    homeTab
                    
                    statsTab
                    
                    settingsTab
                }
            }
        }
        .blur(radius: hideContent ? Vars.privacyBlur : 0)
        .animation(.easeOut(duration: 0.1), value: hideContent)
        .ignoresSafeArea()
        .onOpenURL { url in
            if url == .addExpenseAction {
                addExpenseAction = true
            }
        }
        .onChange(of: scenePhase) { value in
            scenePhaseChange(value)
        }
        .environmentObject(cdm)
        .environmentObject(rvm)
        .sheet(isPresented: $presentOnboarding) {
            OnboardingView()
                .environmentObject(cdm)
                .accentColor(.orange)
                .interactiveDismissDisabled()
        }
        .tint(colorIdentifier(color: tint))
        .accentColor(colorIdentifier(color: tint))
//        .preferredColorScheme(themeConvert(autoDarkMode: autoDarkMode, darkMode: darkMode))
        .onAppear {
            setColorScheme()
        }
        .customAlert()
        .alert(
            "Something went wrong...",
            isPresented: $errorHandler.showAlert,
            presenting: errorHandler.appError
        ) { error in
            if error.createIssue {
                Button("Create an issue on GitHub") {
                    errorHandler.dropError()
                    openURL(.newGithubIssue)
                }
            }
            
            Button("OK", role: .cancel) {
                errorHandler.dropError()
            }
        } message: { error in
            Text("\(error.errorDescription)\n\(error.recoverySuggestion)")
        }
        .styleListsToDynamicType()
#endif
    }
    
    private var homeTab: some View {
        HomeView(showingSheet: $addExpenseAction, presentOnboarding: $presentOnboarding)
        .environmentObject(barChartViewModel)
        .tabItem {
            Label("Home", systemImage: "house.fill")
        }
        .tag(0)
    }
    
    private var statsTab: some View {
        StatsView(scrollToTop: $scrollToTop)
            .environmentObject(pieChartViewModel)
            .environmentObject(filtersViewModel)
            .environmentObject(statsSearchViewModel)
            .environmentObject(statsListViewModel)
            .environmentObject(privacyMonitor)
            .environmentObject(statsViewModel)
            .sheet(item: $statsViewModel.entityToEdit) {
                statsViewModel.edit = false
            } content: { entity in
                SpendingCompleteView(
                    edit: $statsViewModel.edit,
                    entity: entity
                )
                .smallSheet(0.7)
                .environmentObject(privacyMonitor)
                .environmentObject(cdm)
                .environmentObject(rvm)
            }
            .sheet(item: $statsViewModel.entityToAddReturn) { entity in
                AddReturnView(spending: entity, cdm: cdm, rvm: rvm)
                    .accentColor(colorIdentifier(color: tint))
                    .tint(colorIdentifier(color: tint))
            }
            .tabItem {
                Label("Stats", systemImage: "chart.pie.fill")
            }
            .tag(1)
    }
    
    private var settingsTab: some View {
        SettingsView(
            showDarkModeToggle: !autoDarkMode,
            presentOnboarding: $presentOnboarding,
            scrollToTop: $scrollToTop
        )
        .environmentObject(privacyMonitor)
        .environmentObject(pieChartViewModel)
        .tabItem {
            Label("Settings", systemImage: "gearshape.fill")
        }
        .tag(2)
    }
    
    private func setColorScheme() {
        if !autoDarkMode {
            let scenes = UIApplication.shared.connectedScenes
            let windowScene = scenes.first as? UIWindowScene
            let window = windowScene?.windows.first
            window?.overrideUserInterfaceStyle = darkMode ? .dark : .light
        }
    }
    
    private func scenePhaseChange(_ value: ScenePhase) {
        if value == .inactive {
            WidgetsManager.shared.reloadSumWidgets()
            WidgetsManager.shared.updateAccentColor()
        }
        
        if privacyScreenIsEnabled {
            hideContent = value != .active
        }
        
        privacyMonitor.changePrivacyScreenValue(value != .active)
        
        if value == .active {
            rvm.checkForUpdate()
            
            if let lastFetchDate = cdm.lastFetchDate, !Calendar.current.isDateInToday(lastFetchDate) {
                cdm.fetchSpendings(updateWidgets: false)
            }
            
            #if DEBUG
            Logger(subsystem: Vars.appIdentifier, category: #fileID).log("Moved to foreground, CD last fetch: \((cdm.lastFetchDate ?? .distantFuture).formatted(date: .numeric, time: .standard))")
            #endif
        }
    }
}

#if DIME_QA
private struct DimeQARoot: View {
    @ObservedObject var coreDataModel: CoreDataModel
    @ObservedObject var ratesViewModel: RatesViewModel
    @State private var presentOnboarding = false
    @State private var statsScrollToTop: Int?
    @State private var settingsScrollToTop: Int?

    var body: some View {
#if DIME_QA
        if ProcessInfo.processInfo.arguments.contains("-dimeQA-category-editor") {
            DimeCategoryEditorQAHarness(
                focusName: ProcessInfo.processInfo.arguments.contains("-dimeQA-focus-name")
            )
            .environmentObject(coreDataModel)
        } else {
            dimeHome
        }
#else
        dimeHome
#endif
    }

    private var dimeHome: some View {
        GeometryReader { proxy in
            DimeHomeView(
                presentOnboarding: $presentOnboarding,
                statsScrollToTop: $statsScrollToTop,
                settingsScrollToTop: $settingsScrollToTop,
                topEdge: proxy.safeAreaInsets.top,
                bottomEdge: proxy.safeAreaInsets.bottom
            )
            .environmentObject(coreDataModel)
            .environmentObject(ratesViewModel)
        }
    }
}

#if DIME_QA
private struct DimeCategoryEditorQAHarness: View {
    let focusName: Bool
    @State private var showEditor = true

    var body: some View {
        NavigationView {
            NavigationLink(isActive: $showEditor) {
                AddCategoryView(
                    selectedCategory: .constant(nil),
                    insert: false,
                    colors: [],
                    unusedColors: [],
                    oklch: OKLCH(lightness: 0.9, chroma: CategoryColorValues.chroma),
                    initiallyFocusName: focusName
                )
            } label: {
                EmptyView()
            }
            .hidden()
            .navigationTitle("Categories")
        }
        .navigationViewStyle(.stack)
    }
}
#endif
#endif

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
