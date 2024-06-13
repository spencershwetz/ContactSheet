//
//  PickerView.swift
//  Contact Sheet
//
//  Created by Windy on 12/06/24.
//

import UIKit

struct Ratio: Equatable {
    let width: CGFloat
    let height: CGFloat
    
    var formattedText: String {
        if self == .random {
            return "Custom"
        } else {
            let widthString = width.truncatingRemainder(dividingBy: 1) == 0 ? String(
                format: "%.0f",
                width
            ) : "\(width)"
            let heightString = height.truncatingRemainder(dividingBy: 1) == 0 ? String(
                format: "%.0f",
                height
            ) : "\(height)"
            return "\(widthString) : \(heightString)"
        }
    }
    
    static let random = Ratio(width: 0, height: 0)
}

final class RatioPickerView: UIView {
    
    private let titleLabel = UILabel()
    private let textField = UITextField()
    private let pickerView = UIPickerView()
    private let selections: [Ratio]
    
    var selectedRatio: Ratio? {
        didSet {
            textField.text = selectedRatio?.formattedText
        }
    }
    
    private let onSelect: (Ratio) -> Void
    
    init(title: String, selections: [Ratio], onSelect: @escaping (Ratio) -> Void) {
        self.selections = selections
        self.onSelect = onSelect
        super.init(frame: .zero)
        setupToolBar()

        titleLabel.text = title
        titleLabel.font = .preferredFont(forTextStyle: .title3)
        textField.tintColor = .clear
        textField.font = .preferredFont(forTextStyle: .title3)
        textField.inputView = pickerView
        
        pickerView.delegate = self
        pickerView.dataSource = self
        
        let stackView = HStackView(
            distribution: .equalCentering,
            arrangedSubviews: [titleLabel, textField]
        )
        addSubview(stackView)
        
        NSLayoutConstraint.activate([
            stackView.topAnchor.constraint(equalTo: topAnchor),
            stackView.bottomAnchor.constraint(equalTo: bottomAnchor),
            stackView.leadingAnchor.constraint(equalTo: leadingAnchor),
            stackView.trailingAnchor.constraint(equalTo: trailingAnchor)
        ])
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupToolBar() {
        let toolBar = UIToolbar()
        toolBar.sizeToFit()

        let doneButton = UIBarButtonItem(
            title: "Done",
            style: UIBarButtonItem.Style.done,
            target: self,
            action: #selector(handleDoneAction)
        )
        let flexSpace = UIBarButtonItem(
            barButtonSystemItem: .flexibleSpace,
            target: nil,
            action: nil
        )
        toolBar.setItems([flexSpace, doneButton], animated: false)
        
        textField.inputAccessoryView = toolBar
    }
    
    @objc
    private func handleDoneAction() {
        textField.resignFirstResponder()
    }
}

extension RatioPickerView: UIPickerViewDataSource, UIPickerViewDelegate {
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        1
    }

    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        selections.count
    }
    
    func pickerView(
        _ pickerView: UIPickerView,
        titleForRow row: Int,
        forComponent component: Int
    ) -> String? {
        selections[row].formattedText
    }

    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        textField.text = selections[row].formattedText
        textField.resignFirstResponder()
        onSelect(selections[row])
    }
}

extension RatioPickerView {

    static func pageSizePicker(onSelect: @escaping (Ratio) -> Void) -> RatioPickerView {
        RatioPickerView(
            title: "Page Size",
            selections: [
                Ratio(width: 16, height: 9),
                Ratio(width: 9, height: 16),
                Ratio(width: 1, height: 1)
            ],
            onSelect: onSelect
        )
    }

    static func photoAspectRatioPicker(onSelect: @escaping (Ratio) -> Void) -> RatioPickerView {
        RatioPickerView(
            title: "Photo Aspect Ratio",
            selections: [
                Ratio(width: 1, height: 1),
                Ratio(width: 16, height: 9),
                Ratio(width: 9, height: 16),
                Ratio(width: 17, height: 9),
                Ratio(width: 2.35, height: 1),
                Ratio(width: 2.2, height: 1),
                Ratio(width: 4, height: 5),
                Ratio(width: 5, height: 7),
                Ratio(width: 4, height: 3),
                Ratio(width: 3, height: 5),
                Ratio(width: 3, height: 2),
                .random
            ],
            onSelect: onSelect
        )
    }
}
