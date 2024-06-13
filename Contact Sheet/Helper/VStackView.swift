//
//  VStackView.swift
//  Contact Sheet
//
//  Created by Windy on 12/06/24.
//

import UIKit

final class VStackView: UIStackView {
    
    init(
        spacing: CGFloat = 8,
        alignment: UIStackView.Alignment = .fill,
        distribution: UIStackView.Distribution = .fill,
        arrangedSubviews: [UIView]
    ) {
        super.init(frame: .zero)
        self.spacing = spacing
        self.distribution = distribution
        self.alignment = alignment
        self.axis = .vertical
        self.translatesAutoresizingMaskIntoConstraints = false
        arrangedSubviews.forEach(addArrangedSubview)
    }
    
    required init(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

