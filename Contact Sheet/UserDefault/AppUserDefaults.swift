//
//  UserDefault.swift
//  Contact Sheet
//
//  Created by Windy on 15/06/24.
//

import Foundation

struct AppUserDefaults {
    
    private init() {}
    
    static let userDefault = UserDefaults.standard
    
    enum Key: String {
        case enabledICloudSync
    }
    
    static func bool(forKey key: Key) -> Bool {
        userDefault.bool(forKey: key.rawValue)
    }
    
    static func string(forKey key: Key) -> String? {
        userDefault.string(forKey: key.rawValue)
    }
}
