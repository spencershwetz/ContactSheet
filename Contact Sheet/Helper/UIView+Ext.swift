//
//  UIView+Ext.swift
//  Contact Sheet
//
//  Created by Windy on 05/07/24.
//

import UIKit

extension UIView {
    
    @discardableResult
    func isHidden(_ isHidden: Bool) -> Self {
        self.isHidden = isHidden
        return self
    }
}
