//
//  CreateViewController.swift
//  Contact Sheet
//
//  Created by Windy on 12/06/24.
//

import UIKit
import Combine

final class CreateViewController: UIViewController {

    @State private var pageSizeRatio: Ratio = .init(width: 16, height: 9)
    @State private var photoAspectRatio: Ratio = .init(width: 1, height: 1)

    private var subscriptions = Set<AnyCancellable>()
    
    private lazy var pageSizePicker = RatioPickerView
        .pageSizePicker(onSelect: { [weak self] in
            print("@@@", $0)
        })
    private lazy var photoAspectRatioPicker = RatioPickerView
        .photoAspectRatioPicker(onSelect: { [weak self] in
            if $0 == .random {
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
        self?.gridView.totalRow = $0
    })

    private let columnLabel = UILabel()
    private lazy var columnStepper = makeStepper(onValueChanged: { [weak self] in
        self?.gridView.totalColumn = $0
    })

    private lazy var rowStackView = VStackView(
        arrangedSubviews: [rowLabel, rowStepper]
    )
    private lazy var columnStackView = VStackView(
        alignment: .trailing,
        arrangedSubviews: [columnLabel, columnStepper]
    )

    private lazy var gridView = CreateGridView()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        bind()
        setupHeader()
        setupRowAndColumnStepperLabel()
        setupGrid()
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
        
        gridView.$totalRow
            .sink { [weak self] in self?.rowLabel.text = "Rows \($0)" }
            .store(in: &subscriptions)
        
        gridView.$totalColumn
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
        stepper.value = Double(gridView.totalColumn)
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
