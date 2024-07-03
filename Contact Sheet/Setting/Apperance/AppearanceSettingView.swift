//
//  AppearanceSettingView.swift
//  Contact Sheet
//
//  Created by Windy on 03/07/24.
//

import UIKit

enum Appearance: Int {
    case system = 0
    case light
    case dark
}

final class AppearanceSettingView: UIView {
    
    private let label = UILabel()
        .text("Appearance")
    
    private lazy var segmentedControl = {
        let segmentedControl = UISegmentedControl(items: ["System", "Light", "Dark"])
        segmentedControl.selectedSegmentIndex = AppUserDefaults.integer(forKey: .appearance)
        segmentedControl.addAction(UIAction(handler: { _ in
            let value = Appearance(rawValue: segmentedControl.selectedSegmentIndex)
            AppUserDefaults.setValue(value?.rawValue, forKey: .appearance)
            AppearanceSwitcher.setStyle(value ?? .system)
        }), for: .valueChanged)
        return segmentedControl
    }()
    
    init() {
        super.init(frame: .zero)
    
        let hStackview = HStackView(
            distribution: .equalCentering,
            arrangedSubviews: [label, segmentedControl]
        ).margin(.init(top: 8, left: 16, bottom: 8, right: 16))

        addSubview(hStackview, constraint: .fill)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

