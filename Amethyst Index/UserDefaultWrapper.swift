//
//  UserDefaultWrapper.swift
//  Amethyst Index
//
//  Created by Mia Koring on 12.07.25.
//
import Foundation

protocol UserDefaultWrapper: CaseIterable, RawRepresentable where RawValue == String  {
    static var defaults: UserDefaults { get }
}
extension UserDefaultWrapper {
    func reset() {
        for setting in Self.allCases {
            Self.defaults.removeObject(forKey: setting.key)
        }
    }
    
    var key: String {
        switch self {
        default: self.rawValue
        }
    }

    var stringValue: String {
        get { Self.defaults.string(forKey: self.key) ?? "" }
        nonmutating set { Self.defaults.setValue(newValue, forKey: self.key) }
    }

    var intValue: Int {
        get { Self.defaults.integer(forKey: self.key) }
        nonmutating set { Self.defaults.setValue(newValue, forKey: self.key) }
    }

    var doubleValue: Double {
        get { Self.defaults.double(forKey: self.key) }
        nonmutating set { Self.defaults.setValue(newValue, forKey: self.key) }
    }

    var boolValue: Bool {
        get { Self.defaults.bool(forKey: self.key) }
        nonmutating set { Self.defaults.setValue(newValue, forKey: self.key) }
    }
    
    var data: Data? {
        get { Self.defaults.data(forKey: self.key) }
        nonmutating set { Self.defaults.setValue(newValue, forKey: self.key) }
    }

    var value: Any? {
        get { Self.defaults.object(forKey: self.key) }
        nonmutating set { Self.defaults.setValue(newValue, forKey: self.rawValue) }
    }
    
    func stringValue(default defaultValue: String) -> String {
        Self.defaults.string(forKey: self.key) ?? defaultValue
    }
}
