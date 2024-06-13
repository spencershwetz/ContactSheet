//
//  UILabel+Ext.swift
//  Contact Sheet
//
//  Created by Windy on 12/06/24.
//

import UIKit

extension UILabel {
    
    @discardableResult
    func text(_ text: String?) -> Self {
        self.text = text
        return self
    }
    
    @discardableResult
    func font(_ font: UIFont) -> Self {
        self.font = font
        return self
    }
}
