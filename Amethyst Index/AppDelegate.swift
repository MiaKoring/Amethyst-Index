//
//  AppDelegate.swift
//  Amethyst Index
//
//  Created by Mia Koring on 12.07.25.
//
import SwiftUI

@Observable
class AppDelegate: NSObject, NSApplicationDelegate {
    
    static let settingsGroupID: String = {
        guard let teamID = Bundle.main.object(forInfoDictionaryKey: "TeamID") as? String else { fatalError("TeamID not found")}
        return "\(teamID)group.de.touchthegrass.Amethyst.Index"
    }()

    var window: NSWindow!
    
    // Create an instance of our controller.
    let meiliSearchController: MeiliSearchController?
    private let meiliURL: String
    
    override init() {
        let url = Settings.meiliURL.stringValue(default: "127.0.0.1:37270")
        guard let masterKey = KeyChainManager.getValue(for: KeychainKey.meiliMasterKey) else {
            self.meiliSearchController = nil
            self.meiliURL = url
            super.init()
            print("Couldn't start meilisearch")
            return
        }
        self.meiliURL = url
        self.meiliSearchController = MeiliSearchController(url: url, masterKey: masterKey)
        try? self.meiliSearchController?.start()
        super.init()
    }

    func applicationDidFinishLaunching(_ aNotification: Notification) {
        // Start Meilisearch when the app has finished launching.
        let url = Settings.meiliURL.stringValue
        if !url.isEmpty {
            do {
                try meiliSearchController?.start()
            } catch {
                // Handle the error, e.g., by showing an alert to the user.
                print("Failed to start Meilisearch: \(error.localizedDescription)")
                // You might want to present a fatal error alert here.
            }
        }
    }

    func applicationWillTerminate(_ aNotification: Notification) {
        // Stop Meilisearch when the app is about to quit.
        // This is crucial for a clean shutdown.
        meiliSearchController?.stop()
    }
}
