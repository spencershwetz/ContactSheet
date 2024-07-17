//
//  ICloudSettingView.swift
//  Contact Sheet
//
//  Created by Windy on 29/06/24.
//

import UIKit
import Combine
import SwiftUI

final class CloudSettingView: UIView {

    private let textLabel = UILabel()
        .text("Enable iCloud Sync")

    private let syncInformationLabel = UILabel()
        .textColor(.secondaryLabel)
        .font(.preferredFont(forTextStyle: .footnote))

    private lazy var toggle = {
        let toggle = UISwitch()
        toggle.isOn = AppUserDefaults.bool(forKey: .enabledICloudSync)
        toggle.addAction(UIAction(handler: { _ in
            AppUserDefaults.setValue(toggle.isOn, forKey: .enabledICloudSync)
        }), for: .valueChanged)
        return toggle
    }()

    private var syncInformationSubscriptions: AnyCancellable?

    private let onUpdate: () -> Void

    init(onUpdate: @escaping () -> Void) {
        self.onUpdate = onUpdate

        super.init(frame: .zero)

        syncInformationSubscriptions = CloudKitSyncMonitor.shared.$lastSyncDate
            .sink { [weak self] in
                self?.onUpdate()
                self?.syncInformationLabel.text = "Last sync at \($0)"
                self?.syncInformationLabel.isHidden = $0.isEmpty
            }

        let hStackview = HStackView(
            distribution: .equalCentering,
            arrangedSubviews: [textLabel, toggle]
        )

        let mainStackView = VStackView(spacing: 0, arrangedSubviews: [hStackview, syncInformationLabel])
            .margin(.init(top: 8, left: 16, bottom: 8, right: 16))
        addSubview(mainStackView, constraint: .fill)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

#Preview(body: {
    CloudSyncHistoryCell().asPreview()
})


final class CloudSyncHistoryCell: UIView {

    private let textLabel = UILabel()
        .text("Show History")

    init() {
        super.init(frame: .zero)

        let mainStackView = VStackView(spacing: 0, arrangedSubviews: [textLabel])
            .margin(.init(top: 10, left: 16, bottom: 10, right: 16))
        addSubview(mainStackView, constraint: .fill)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
