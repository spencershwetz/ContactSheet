//
//  AppearanceSwitcher.swift
//  Contact Sheet
//
//  Created by Windy on 03/07/24.
//

import UIKit

struct AppearanceSwitcher {
    
    static func setStyle(_ appearance: Appearance) {
        guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene
        else { return }
        
        guard let sceneDelegate = windowScene.delegate as? SceneDelegate else { return }
        sceneDelegate.window?.overrideUserInterfaceStyle = appearance.value()
    }
}

private extension Appearance {
    
    func value() -> UIUserInterfaceStyle {
        switch self {
        case .system: .unspecified
        case .light: .light
        case .dark: .dark
        }
    }
}
