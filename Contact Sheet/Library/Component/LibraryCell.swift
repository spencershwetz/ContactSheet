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

    private let photoView: UIImageView = UIImageView()
    private let selectImageView: UIImageView = UIImageView()
    var aspectRatio = Ratio(width: 1, height: 1)
    private var photoViewWidthConstraint: NSLayoutConstraint?
    private var photoViewHeigthConstraint: NSLayoutConstraint?
    private var labelHeightConstraint: NSLayoutConstraint?
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
    let titleLabel: UILabel = UILabel()

    static let identifier = String(describing: LibraryCell.self)
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        photoView.layer.borderWidth = 0.5
        photoView.layer.borderColor = UIColor.label.cgColor
        contentView.clipsToBounds = true

        titleLabel.font = .preferredFont(forTextStyle: .body)
        titleLabel.textColor = .label
        titleLabel.clipsToBounds = true
        titleLabel.numberOfLines = 2
        titleLabel.textAlignment = .center
        titleLabel.minimumScaleFactor = 0.8
        titleLabel.adjustsFontSizeToFitWidth = true


        photoView.clipsToBounds = true
        photoView.contentMode = .scaleAspectFill
        photoView.translatesAutoresizingMaskIntoConstraints = false
        

        let contentStackView = VStackView(arrangedSubviews: [
            titleLabel,
            photoView
        ])

        contentView.addSubview(contentStackView)

        NSLayoutConstraint.activate([
            photoView.topAnchor.constraint(equalTo: contentView.topAnchor),
            photoView.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            photoView.bottomAnchor.constraint(equalTo: titleLabel.topAnchor),
            photoView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            titleLabel.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            titleLabel.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
            titleLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 5),
            titleLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -5)
        ])
        photoViewHeigthConstraint = photoView.heightAnchor.constraint(equalToConstant: 0)
        photoViewHeigthConstraint?.isActive = true
        photoViewWidthConstraint = photoView.widthAnchor.constraint(equalToConstant: 0)
        photoViewWidthConstraint?.isActive = true
        labelHeightConstraint = titleLabel.heightAnchor.constraint(equalToConstant: 0)
        labelHeightConstraint?.isActive = true

        contentView.addInteraction(UIContextMenuInteraction(delegate: self))
        contentView.isUserInteractionEnabled = true

        selectImageView.image = UIImage(systemName: "circle")
        contentView.addSubview(selectImageView)
        selectImageView.isHidden = true

    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        let (width, height): (CGFloat, CGFloat)

        if aspectRatio.width > aspectRatio.height {
            width = contentView.bounds.width
            let totalHeight = (aspectRatio.height * width / aspectRatio.width)
            height = totalHeight - 50
        } else {
            let totalHeight = contentView.bounds.height
            height = totalHeight - 50
            width = aspectRatio.width * totalHeight / aspectRatio.height
        }

        photoViewWidthConstraint?.constant = width
        photoViewHeigthConstraint?.constant = height
        labelHeightConstraint?.constant = 50
        selectImageView.frame = .init(
            x: contentView.bounds.width - 35,
            y: contentView.bounds.height - 85,
            width: 30,
            height: 30
        )
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

/**
-- I would like the library screen to look like the screenshot:
-- thumbnail of each project with the project name beneath it
-- The ability for the user to click a thumbnail and be taken to the create page
--  A select button in the upper right corner that allows the user to select multiple projects to share or delete  or merge together (merging creates a new project with all the images merges to the same project)

 */
