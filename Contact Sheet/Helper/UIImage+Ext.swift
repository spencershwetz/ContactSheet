//
//  UIImage+Ext.swift
//  Contact Sheet
//
//  Created by Windy on 15/06/24.
//

import UIKit

extension UIImage {

    static func load(url: URL?) -> UIImage? {
        guard let url, let data = try? Data(contentsOf: url) else { return nil }
        return UIImage(data: data)
    }
}
