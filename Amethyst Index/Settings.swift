//
//  GroupDefaults.swift
//  Amethyst Index
//
//  Created by Mia Koring on 12.07.25.
//
import Foundation

enum Settings: String, UserDefaultWrapper {
    case meiliURL
    
    static let defaults: UserDefaults = UserDefaults(suiteName: AppDelegate.settingsGroupID)!
}
