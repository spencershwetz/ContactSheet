//
//  View+Extensions.swift
//  Contact Sheet
//
//  Created by Jaymeen Unadkat on 06/07/24.
//

import Foundation
import SwiftUI


extension View {
    func snapshot(withBackgroundColor: Color) -> UIImage? {
        let controller = UIHostingController(
            rootView: self.ignoresSafeArea().fixedSize(horizontal: true, vertical: true))
        guard let view = controller.view else { return nil }

        let targetSize = view.intrinsicContentSize // to capture entire scroll content
        if targetSize.width <= 0 || targetSize.height <= 0 { return nil }

        view.bounds = CGRect(origin: .zero, size: targetSize)
        view.backgroundColor = UIColor(withBackgroundColor) // set it to clear if no background color is preffered

        let renderer = UIGraphicsImageRenderer(size: targetSize)
        return renderer.image { rendereContext in
            view.drawHierarchy(in: controller.view.bounds, afterScreenUpdates: true)
        }
    }
}

extension UIApplication {

    static let keyWindow = UIApplication.shared.connectedScenes
        .filter({$0.activationState == .foregroundActive})
        .compactMap({$0 as? UIWindowScene})
        .first?.windows
        .filter({$0.isKeyWindow}).first

}
