//
//  UIButton+Ext.swift
//  Contact Sheet
//
//  Created by Windy on 12/06/24.
//

import UIKit

extension UIButton {
    
    @discardableResult
    func onTapAction(_ onTapAction: @escaping () -> Void) -> Self {
        addAction(UIAction(handler: { _ in
            onTapAction()
        }), for: .touchUpInside)
        return self
    }
}
