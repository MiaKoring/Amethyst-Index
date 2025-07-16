//
//  MeiliSearchController.swift
//  Amethyst Index
//
//  Created by Mia Koring on 12.07.25.
//
import Foundation
import os.log

private let logger = Logger(
    subsystem: "de.touchthegrass.Amethyst-Index",
    category: "MeiliSearchController"
)

@Observable
class MeiliSearchController {
    init(url: String, masterKey: String) {
        self.url = url
        self.masterKey = masterKey
    }
    
    let url: String
    let masterKey: String

    private var meilisearchProcess: Process?
    
    var isRunning: Bool {
        meilisearchProcess != nil
    }

    // MARK: - Public API

    func start() throws {
        guard meilisearchProcess == nil else {
            logger.info("Meilisearch process is already running.")
            return
        }

        guard let binaryUrl = Bundle.main.url(
            forResource: "meilisearch",
            withExtension: nil
        ) else {
            throw MeiliSearchError.binaryNotFound
        }

        try setExecutablePermission(for: binaryUrl)


        // Get the path to the Application Support directory for our app.
        let appSupportDir = try getApplicationSupportDirectory()
        
        // Define the specific path for Meilisearch's data.
        let meiliDbPath = appSupportDir
            .appendingPathComponent("meilisearch-data")
            .path

        logger.info("Meilisearch database path will be: \(meiliDbPath)")

        let process = Process()
        process.executableURL = binaryUrl
        
        process.currentDirectoryURL = appSupportDir

        process.arguments = [
            "--db-path", meiliDbPath,
            "--http-addr", url,
            "--master-key", masterKey,
        ]

        let outputPipe = Pipe()
        let errorPipe = Pipe()
        process.standardOutput = outputPipe
        process.standardError = errorPipe

        outputPipe.fileHandleForReading.readabilityHandler = { fileHandle in
            if let line = String(
                data: fileHandle.availableData,
                encoding: .utf8
            ) {
                if !line.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                    logger.debug("Meilisearch stdout: \(line)")
                }
            }
        }

        errorPipe.fileHandleForReading.readabilityHandler = { fileHandle in
            if let line = String(
                data: fileHandle.availableData,
                encoding: .utf8
            ) {
                if !line.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                    logger.error("Meilisearch stderr: \(line)")
                }
            }
        }

        try process.run()
        self.meilisearchProcess = process
        logger.info("Meilisearch process started successfully.")
    }

    func stop() {
        guard let process = meilisearchProcess else {
            logger.info("Meilisearch process is not running, nothing to stop.")
            return
        }
        logger.info("Terminating Meilisearch process...")
        process.terminate()
        process.waitUntilExit()
        self.meilisearchProcess = nil
        logger.info("Meilisearch process terminated.")
    }

    // MARK: - Private Helpers

    /// Finds or creates a directory for your app in the user's Application Support folder.
    /// - Returns: The URL of the directory.
    /// - Throws: An error if the directory cannot be found or created.
    private func getApplicationSupportDirectory() throws -> URL {
        let fileManager = FileManager.default
        
        // Get the URL for the user's Application Support directory.
        guard let appSupportURL = fileManager.urls(
            for: .applicationSupportDirectory,
            in: .userDomainMask
        ).first else {
            throw MeiliSearchError.appSupportDirectoryNotFound
        }

        // Append your app's name (or bundle identifier) to create a unique folder.
        // Using the bundle identifier is a robust way to do this.
        let bundleId = Bundle.main.bundleIdentifier ?? "YourDefaultAppName"
        let appDirectoryURL = appSupportURL.appendingPathComponent(bundleId)

        // Create the directory if it doesn't exist.
        // `withIntermediateDirectories: true` creates parent directories if needed.
        do {
            try fileManager.createDirectory(
                at: appDirectoryURL,
                withIntermediateDirectories: true,
                attributes: nil
            )
            return appDirectoryURL
        } catch {
            logger.error(
                "Could not create Application Support directory: \(error.localizedDescription)"
            )
            throw MeiliSearchError.appSupportDirectoryCreationError(error)
        }
    }

    private func setExecutablePermission(for url: URL) throws {
        let permissions = 0o755
        do {
            try FileManager.default.setAttributes(
                [.posixPermissions: permissions],
                ofItemAtPath: url.path
            )
        } catch {
            logger.error(
                "Failed to set executable permission on \(url.path): \(error.localizedDescription)"
            )
            throw MeiliSearchError.permissionError(error)
        }
    }
}

// Update your custom errors to include the new cases.
enum MeiliSearchError: Error, LocalizedError {
    case binaryNotFound
    case permissionError(Error)
    case appSupportDirectoryNotFound
    case appSupportDirectoryCreationError(Error)

    var errorDescription: String? {
        switch self {
            case .binaryNotFound:
                return "The Meilisearch binary could not be found in the app bundle."
            case .permissionError(let underlyingError):
                return "Failed to set executable permission: \(underlyingError.localizedDescription)"
            case .appSupportDirectoryNotFound:
                return "Could not find the user's Application Support directory."
            case .appSupportDirectoryCreationError(let underlyingError):
                return "Could not create the app-specific directory in Application Support: \(underlyingError.localizedDescription)"
        }
    }
}
