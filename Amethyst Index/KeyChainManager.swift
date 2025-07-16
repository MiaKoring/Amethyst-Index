//
//  KeyChainManager.swift
//  Amethyst Index
//
//  Created by Mia Koring on 13.07.25.
//


import Foundation
import KeychainAccess

struct KeyChainManager {
    static private let service = "de.touchthegrass.Amethyst-Index.app"
    static func setValue(_ value: String?, for key: KeychainKey) {
        let kc = Keychain(service: KeyChainManager.service).synchronizable(false).accessibility(.alwaysThisDeviceOnly)
        kc[key.rawValue] = value
    }
    
    static func getValue(for key: KeychainKey) -> String? {
        let kc = Keychain(service: KeyChainManager.service).synchronizable(false).accessibility(.alwaysThisDeviceOnly)
        return kc[key.rawValue]
    }

    static func generateSecureKey(length: Int) -> String? {
        var keyData = Data(count: length)
        let result = keyData.withUnsafeMutableBytes { buffer in
            SecRandomCopyBytes(kSecRandomDefault, length, buffer.baseAddress!)
        }
        
        guard result == errSecSuccess else {
            print("Failed to generate random bytes: \(result)")
            return nil
        }
        
        return keyData.base64EncodedString()
    }
}
