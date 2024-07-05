//
//  LibraryThumbnailContentView.swift
//  Contact Sheet
//
//  Created by Windy on 22/06/24.
//

import UIKit

final class LibraryThumbnailContentView: UIView {
    
    private let spacing: CGFloat = 4
    
    var images: [String?] = [] {
        didSet {
            mainStackView.arrangedSubviews.forEach { $0.removeFromSuperview() }
            images.grouped(by: 2).forEach { addHorizontalView(images: $0) }
        }
    }

    var ratio: Ratio = .init(width: 2, height: 1)
    
    private lazy var mainStackView = VStackView(spacing: spacing, arrangedSubviews: [])
        .margin(.all(spacing))
    
    init() {
        super.init(frame: .zero)
        addSubview(mainStackView, constraint: .fill)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func addHorizontalView(images: [String?]) {
        mainStackView.addArrangedSubview(
            HStackView(
                spacing: spacing,
                arrangedSubviews: images.map {
                    LibraryThumbnailImageView()
                        .imageURL($0)
                        .aspectRatio(ratio.height / ratio.width)
                }
            )
        )
    }
}

private extension Array {
    func grouped(by groupSize: Int) -> [[Element]] {
        guard groupSize > 0 else { return [] }
        
        var result: [[Element]] = []
        var currentGroup: [Element] = []
        
        for element in self {
            currentGroup.append(element)
            if currentGroup.count == groupSize {
                result.append(currentGroup)
                currentGroup = []
            }
        }
        
        if !currentGroup.isEmpty {
            result.append(currentGroup)
        }
        
        return result
    }
}
