//
//  Amethyst_IndexApp.swift
//  Amethyst Index
//
//  Created by Mia Koring on 12.07.25.
//

import SwiftUI

@main
struct Amethyst_IndexApp: App {
    @NSApplicationDelegateAdaptor private var appDelegate: AppDelegate
    var isRunning: Bool {
        appDelegate.meiliSearchController?.isRunning ?? false
    }
    var body: some Scene {
        MenuBarExtra {
            Text("Running: \(isRunning ? "🟢": "🔴")")
            Button(isRunning ? "Stop": "Start") {
                if isRunning {
                    appDelegate.meiliSearchController?.stop()
                } else {
                    try? appDelegate.meiliSearchController?.start()
                }
            }
            .disabled(appDelegate.meiliSearchController == nil)
            Button("Launch on Login") {
                let url = URL(string: "x-apple.systempreferences:com.apple.LoginItems-Settings.extension")!
                NSWorkspace.shared.open(url)
            }
            Button("Quit") {
                appDelegate.meiliSearchController?.stop()
                NSApplication.shared.terminate(self)
            }
        } label: {
            Image(systemName: "text.page.badge.magnifyingglass")
        }
    }
}
