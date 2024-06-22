//
//  LibraryCell.swift
//  Contact Sheet
//
//  Created by Windy on 15/06/24.
//

import UIKit
import SwiftUI

final class LibraryCell: UICollectionViewCell {
    
    var onExport: (() -> Void)?
    var onDelete: (() -> Void)?
    var onRename: (() -> Void)?

    private let titleLabel = UILabel()
    private let photoView = UIImageView()
    private let selectImageView = UIImageView()

    var isEnableSelection: Bool = false {
        didSet {
            selectImageView.isHidden = !isEnableSelection
        }
    }

    var isImageSelected: Bool = false {
        didSet {
            selectImageView.image = UIImage(systemName: isImageSelected ? "checkmark.circle.fill" : "circle")
        }
    }

    var image: UIImage? {
        didSet {
            photoView.image = image
        }
    }

    var title: String? {
        didSet {
            titleLabel.text = title
        }
    }

    static let identifier = String(describing: LibraryCell.self)
    
    override init(frame: CGRect) {
        super.init(frame: frame)

        contentView.clipsToBounds = true

        titleLabel.font = .preferredFont(forTextStyle: .body)
        titleLabel.textColor = .label
        titleLabel.numberOfLines = 0
        titleLabel.textAlignment = .center

        photoView.layer.borderWidth = 0.5
        photoView.layer.borderColor = UIColor.label.cgColor
        photoView.clipsToBounds = true
        photoView.contentMode = .scaleAspectFill

        let contentStackView = VStackView(spacing: 4, arrangedSubviews: [
            photoView,
            titleLabel
        ])

        contentView.addSubview(contentStackView)

        NSLayoutConstraint.activate([
            photoView.heightAnchor.constraint(equalTo: photoView.widthAnchor, multiplier: 1),
            contentStackView.topAnchor.constraint(equalTo: contentView.topAnchor),
            contentStackView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
            contentStackView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            contentStackView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
        ])

        contentView.addInteraction(UIContextMenuInteraction(delegate: self))
        contentView.isUserInteractionEnabled = true

        selectImageView.image = UIImage(systemName: "circle")
        selectImageView.isHidden = true
        selectImageView.translatesAutoresizingMaskIntoConstraints = false
        photoView.addSubview(selectImageView)
        
        NSLayoutConstraint.activate([
            selectImageView.bottomAnchor.constraint(equalTo: photoView.bottomAnchor, constant: -4),
            selectImageView.trailingAnchor.constraint(equalTo: photoView.trailingAnchor, constant: -4),
            selectImageView.heightAnchor.constraint(equalToConstant: 30),
            selectImageView.widthAnchor.constraint(equalToConstant: 30)
        ])
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        photoView.image = nil
    }
}

extension LibraryCell: UIContextMenuInteractionDelegate {
    
    func contextMenuInteraction(
        _ interaction: UIContextMenuInteraction,
        configurationForMenuAtLocation location: CGPoint
    ) -> UIContextMenuConfiguration? {
        UIContextMenuConfiguration(identifier: nil, previewProvider: nil) { _ in
            let exportAction = UIAction(
                title: "Export",
                image: UIImage(systemName: "square.and.arrow.up"),
                handler: { [weak self] _ in self?.onExport?() }
            )
            let deleteAction = UIAction(
                title: "Delete",
                image: UIImage(systemName: "trash.fill"),
                attributes: .destructive,
                handler: { [weak self] _ in self?.onDelete?() }
            )

            let renameAction = UIAction(
                title: "Rename",
                image: UIImage(systemName: "square.and.pencil"),
                handler: { [weak self] _ in self?.onRename?() }
            )
            return UIMenu(children: [exportAction, renameAction, deleteAction])
        }
    }
}

#Preview(body: {
    LibraryCell().asPreview()
})
