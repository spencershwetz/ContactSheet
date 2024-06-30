//
//  UIStackView+Ext.swift
//  Contact Sheet
//
//  Created by Windy on 29/06/24.
//

import UIKit

extension UIStackView {

    @discardableResult
    func margin(_ margin: UIEdgeInsets) -> Self {
        isLayoutMarginsRelativeArrangement = true
        layoutMargins = margin
        return self
    }
}

extension UIEdgeInsets {

    static func horizontal(_ value: CGFloat) -> UIEdgeInsets {
        .init(top: 0, left: value, bottom: 0, right: value)
    }

    static func all(_ value: CGFloat) -> UIEdgeInsets {
        .init(top: value, left: value, bottom: value, right: value)
    }
}
