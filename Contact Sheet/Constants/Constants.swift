//
//  Constants.swift
//  Contact Sheet
//
//  Created by Jaymeen Unadkat on 24/07/24.
//

import Foundation
import UIKit

struct DeviceType {
    static let IS_IPHONE_4_OR_LESS      = ScreenSize.SCREEN_MAX_LENGTH < 568.0
    static let IS_IPHONE_5              = ScreenSize.SCREEN_MAX_LENGTH == 568.0
    static let IS_IPHONE_6              = ScreenSize.SCREEN_MAX_LENGTH == 667.0
    static let IS_IPHONE_6P             = ScreenSize.SCREEN_MAX_LENGTH == 736.0
    static let IS_IPHONE_X              = ScreenSize.SCREEN_HEIGHT == 812.0
    static let IS_IPHONE_XMAX           = ScreenSize.SCREEN_HEIGHT == 896.0
    static let IS_PAD                   = UIDevice.current.userInterfaceIdiom == .pad
    static let IS_IPAD                  = UIDevice.current.userInterfaceIdiom == .pad && ScreenSize.SCREEN_MAX_LENGTH == 1024.0
    static let IS_IPAD_PRO              = UIDevice.current.userInterfaceIdiom == .pad && ScreenSize.SCREEN_MAX_LENGTH == 1366.0
    static let IsDeviceIPad             = IS_PAD || IS_IPAD || IS_IPAD_PRO ? true : false
}

struct ScreenSize {
    static let SCREEN_WIDTH             = UIScreen.main.bounds.size.width
    static let SCREEN_HEIGHT            = UIScreen.main.bounds.size.height
    static let SCREEN_MAX_LENGTH        = max(ScreenSize.SCREEN_WIDTH, ScreenSize.SCREEN_HEIGHT)
    static let SCREEN_MIN_LENGTH        = min(ScreenSize.SCREEN_WIDTH, ScreenSize.SCREEN_HEIGHT)
}
