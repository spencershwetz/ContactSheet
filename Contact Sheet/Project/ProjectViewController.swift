//
//  CreateViewController.swift
//  Contact Sheet
//
//  Created by Windy on 12/06/24.
//

import UIKit
import Combine
import SwiftUI

final class ProjectViewController: UIViewController {

    struct Config {
        let id: UUID
        let pageSizeRatio: Ratio
        let photoAspectRatio: Ratio
        let photoURLs: [URL?]
        let totalRows: Int
        let totalColumns: Int
        let title: String
    }
    
    @State private var pageSizeRatio: Ratio
    @State private var photoAspectRatio: Ratio

    private let store = ProjectStore.shared
    private var subscriptions = Set<AnyCancellable>()
    
    private lazy var pageSizePicker = RatioPickerView
        .pageSizePicker(onSelect: { [weak self] in
            print("@@@", $0)
        })
    private lazy var photoAspectRatioPicker = RatioPickerView
        .photoAspectRatioPicker(onSelect: { [weak self] in
            if $0 == .random {
                self?.view.endEditing(true)
                self?.showAspectRatioAlert()
            } else {
                self?.photoAspectRatio = $0
            }
        })

    private lazy var headerStackView = VStackView(
        arrangedSubviews: [pageSizePicker, photoAspectRatioPicker]
    )

    private let rowLabel = UILabel()
    private lazy var rowStepper = makeStepper(onValueChanged: { [weak self] in
        self?.gridView.totalRows = $0
    })

    private let columnLabel = UILabel()
    private lazy var columnStepper = makeStepper(onValueChanged: { [weak self] in
        self?.gridView.totalColumns = $0
    })

    private lazy var rowStackView = VStackView(
        arrangedSubviews: [rowLabel, rowStepper]
    )
    private lazy var columnStackView = VStackView(
        alignment: .trailing,
        arrangedSubviews: [columnLabel, columnStepper]
    )

    private lazy var gridView = ProjectGridView()
    
    private let config: Config
    
    init(config: Config) {
        self.config = config
        pageSizeRatio = config.pageSizeRatio
        photoAspectRatio = config.photoAspectRatio
        
        super.init(nibName: nil, bundle: nil)
        
        gridView.photos = config.photoURLs.map { .init(photoURL: $0) }
        gridView.totalColumns = config.totalColumns
        gridView.totalRows = config.totalRows
        gridView.aspectRatio = config.photoAspectRatio
        title = config.title
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = config.title
        view.backgroundColor = .systemBackground
        navigationItem.largeTitleDisplayMode = .never
        bind()
        setupHeader()
        setupRowAndColumnStepperLabel()
        setupGrid()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        store.update(project: Project(
            id: config.id,
            pageSizeRatio: .init(width: pageSizeRatio.width, height: pageSizeRatio.height),
            photoAspectRatio: .init(width: photoAspectRatio.width, height: photoAspectRatio.height),
            totalRows: gridView.totalRows,
            totalColumns: gridView.totalColumns,
            photos: gridView.photos.map(\.photoURL),
            title: config.title
        ))
    }

    override func viewWillTransition(
        to size: CGSize,
        with coordinator: UIViewControllerTransitionCoordinator
    ) {
        super.viewWillTransition(to: size, with: coordinator)
        gridView.invalidateLayout()
    }
    
    private func setupRowAndColumnStepperLabel() {
        let stackView = HStackView(
            distribution: .equalCentering,
            arrangedSubviews: [rowStackView, columnStackView]
        )
        view.addSubview(stackView)
        NSLayoutConstraint.activate([
            stackView.topAnchor.constraint(equalTo: headerStackView.bottomAnchor, constant: 16),
            stackView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            stackView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16)
        ])
    }
    
    private func setupGrid() {
        gridView.viewController = self
        gridView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(gridView)
        NSLayoutConstraint.activate([
            gridView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            gridView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            gridView.topAnchor.constraint(equalTo: columnStackView.bottomAnchor, constant: 16),
            gridView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor)
        ])
    }
    
    private func bind() {
        $pageSizeRatio
            .sink { [weak self] in self?.pageSizePicker.selectedRatio = $0 }
            .store(in: &subscriptions)
        
        $photoAspectRatio
            .sink { [weak self] in
                self?.gridView.aspectRatio = $0
                self?.photoAspectRatioPicker.selectedRatio = $0
            }
            .store(in: &subscriptions)
        
        gridView.$totalRows
            .sink { [weak self] in self?.rowLabel.text = "Rows \($0)" }
            .store(in: &subscriptions)
        
        gridView.$totalColumns
            .sink { [weak self] in self?.columnLabel.text = "Columns \($0)" }
            .store(in: &subscriptions)
    }
    
    private func setupHeader() {
        view.addSubview(headerStackView)

        NSLayoutConstraint.activate([
            headerStackView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            headerStackView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            headerStackView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16)
        ])
    }
    
    private func makeStepper(onValueChanged: @escaping (Int) -> Void) -> UIStepper {
        let stepper = UIStepper()
        stepper.minimumValue = 1
        stepper.value = Double(gridView.totalColumns)
        stepper.addAction(
            UIAction(handler: { action in
                let value = (action.sender as? UIStepper)?.value
                onValueChanged(Int(value ?? 0.0))
            }), for: .valueChanged
        )
        return stepper
    }
    
    private func showAspectRatioAlert() {
        let alert = UIAlertController(
            title: "Enter Ratio",
            message: "Please enter width and height ratios",
            preferredStyle: .alert
        )

        alert.addTextField { textField in
            textField.placeholder = "Width Ratio"
            textField.keyboardType = .decimalPad
        }

        alert.addTextField { textField in
            textField.placeholder = "Height Ratio"
            textField.keyboardType = .decimalPad
        }

        let submitAction = UIAlertAction(
            title: "Okay",
            style: .default
        ) { [unowned alert, weak self] _ in
            guard
                let widthText = alert.textFields![0].text, let widthRatio = Double(widthText),
                let heightText = alert.textFields![1].text, let heightRatio = Double(heightText)
            else {
                return
            }

            self?.photoAspectRatio = Ratio(width: widthRatio, height: heightRatio)
        }

        alert.addAction(submitAction)
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        present(alert, animated: true, completion: nil)
    }
}

#Preview {
    return ProjectViewController(config: initialConfig(id: UUID())).asPreview()

    func initialConfig(id: UUID) -> ProjectViewController.Config {
        ProjectViewController.Config(
            id: id,
            pageSizeRatio: .init(width: 16, height: 9),
            photoAspectRatio: .init(width: 1, height: 1),
            photoURLs: [],
            totalRows: 4,
            totalColumns: 3,
            title: "Untitled Project"
        )
    }
}
