//
//  Amethyst_IndexApp.swift
//  Amethyst Index
//
//  Created by Mia Koring on 12.07.25.
//

import SwiftUI
import Sparkle
internal import Combine

@main
struct Amethyst_IndexApp: App {
    @NSApplicationDelegateAdaptor private var appDelegate: AppDelegate
    private let updaterController: SPUStandardUpdaterController
    
    init() {
        updaterController = SPUStandardUpdaterController(startingUpdater: true, updaterDelegate: nil, userDriverDelegate: nil)
    }

    var body: some Scene {
        MenuBarExtra {
            MenuBarContent(meilisearchController: appDelegate.meiliSearchController, updateController: updaterController)
        } label: {
            Image(systemName: "text.page.badge.magnifyingglass")
        }
    }
    
    struct MenuBarContent: View {
        @State var meilisearchController: MeiliSearchController?
        let updateController: SPUStandardUpdaterController
        
        var isRunning: Bool {
            meilisearchController?.isRunning ?? false
        }
        var versionString: String {
            let infoDictionary = Bundle.main.infoDictionary
            let version = infoDictionary?["CFBundleShortVersionString"] as? String ?? ""
            let build = infoDictionary?["CFBundleVersion"] as? String ?? ""
            return "Amethyst Index \(version) (\(build))"
        }
        
        var body: some View {
            Text("Running: \(isRunning ? "🟢": "🔴")")
            Button(isRunning ? "Stop": "Start") {
                if isRunning {
                    meilisearchController?.stop()
                } else {
                    try? meilisearchController?.start()
                }
            }
            .disabled(meilisearchController == nil)
            Button("Launch on Login") {
                let url = URL(string: "x-apple.systempreferences:com.apple.LoginItems-Settings.extension")!
                NSWorkspace.shared.open(url)
            }
            CheckForUpdatesView(updater: updateController.updater)
            Button("Quit") {
                meilisearchController?.stop()
                NSApplication.shared.terminate(self)
            }
            Text(versionString)
        }
    }
}

// This view model class publishes when new updates can be checked by the user
final class CheckForUpdatesViewModel: ObservableObject {
    
    @Published var canCheckForUpdates = false

    init(updater: SPUUpdater) {
        updater.publisher(for: \.canCheckForUpdates)
            .assign(to: &$canCheckForUpdates)
    }
}

// This is the view for the Check for Updates menu item
// Note this intermediate view is necessary for the disabled state on the menu item to work properly before Monterey.
// See https://stackoverflow.com/questions/68553092/menu-not-updating-swiftui-bug for more info
struct CheckForUpdatesView: View {
    @ObservedObject private var checkForUpdatesViewModel: CheckForUpdatesViewModel
    private let updater: SPUUpdater
    
    init(updater: SPUUpdater) {
        self.updater = updater
        
        // Create our view model for our CheckForUpdatesView
        self.checkForUpdatesViewModel = CheckForUpdatesViewModel(updater: updater)
    }
    
    var body: some View {
        Button("Check for Updates…", action: updater.checkForUpdates)
            .disabled(!checkForUpdatesViewModel.canCheckForUpdates)
    }
}
