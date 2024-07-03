//
//  SettingViewController.swift
//  Contact Sheet
//
//  Created by Windy on 29/06/24.
//

import UIKit

final class SettingViewController: UIViewController {

    enum Setting: CaseIterable {
        case iCloudSync
        case appearance
    }

    private let items = Setting.allCases

    private let tableView = UITableView(frame: .zero, style: .insetGrouped)

    override func viewDidLoad() {
        super.viewDidLoad()
        view.addSubview(tableView, constraint: .fill)
        tableView.dataSource = self
        title = "Setting"
        navigationController?.navigationBar.prefersLargeTitles = true
        navigationItem.largeTitleDisplayMode = .always
        view.backgroundColor = .systemBackground
    }

    private func updateTableViewHeight() {
        UIView.performWithoutAnimation {
            tableView.beginUpdates()
            tableView.endUpdates()
        }
    }
}

extension SettingViewController: UITableViewDataSource {

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        switch items[indexPath.item] {
        case .iCloudSync:
            SettingCellWrapper(
                content: CloudSettingView(onUpdate: { [weak self] in
                    self?.updateTableViewHeight()
                })
            )
        case .appearance:
            SettingCellWrapper(
                content: AppearanceSettingView()
            )
        }
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        items.count
    }
}

final class SettingCellWrapper: UITableViewCell {

    init(content view: UIView) {
        super.init(style: .default, reuseIdentifier: nil)
        view.translatesAutoresizingMaskIntoConstraints = false

        selectionStyle = .none
        contentView.addSubview(view, constraint: .fill)
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

extension UIView {

    enum Constraint {
        case fill
    }

    func addSubview(_ subview: UIView, constraint: Constraint) {
        subview.translatesAutoresizingMaskIntoConstraints = false
        addSubview(subview)

        switch constraint {
        case .fill:
            NSLayoutConstraint.activate([
                subview.leadingAnchor.constraint(equalTo: leadingAnchor),
                subview.trailingAnchor.constraint(equalTo: trailingAnchor),
                subview.topAnchor.constraint(equalTo: topAnchor),
                subview.bottomAnchor.constraint(equalTo: bottomAnchor)
            ])
        }
    }
}
