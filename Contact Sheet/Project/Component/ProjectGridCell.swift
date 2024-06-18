//
//  CreateGridCell.swift
//  Contact Sheet
//
//  Created by Windy on 12/06/24.
//

import UIKit
import SwiftUI

final class ProjectGridCell: UICollectionViewCell {
    
    var onDelete: (() -> Void)?
    var aspectRatio = Ratio(width: 1, height: 1)
    var imageAssetId: String? {
        didSet {
            guard let imageAssetId else { return }
            PhotoAssetStore.shared.getImageWithLocalId(identifier: imageAssetId) { [weak self] image in
                self?.photoView.image = image
            }
        }
    }
    
    static let identifier = String(describing: ProjectGridCell.self)
    
    private let photoView = UIImageView()
    
    private var photoViewWidthConstraint: NSLayoutConstraint?
    private var photoViewHeigthConstraint: NSLayoutConstraint?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        contentView.clipsToBounds = true

        photoView.layer.borderWidth = 0.5
        photoView.layer.borderColor = UIColor.label.cgColor
        photoView.clipsToBounds = true
        photoView.contentMode = .scaleAspectFill
        photoView.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(photoView)
        
        NSLayoutConstraint.activate([
            photoView.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            photoView.centerXAnchor.constraint(equalTo: contentView.centerXAnchor)
        ])
        
        photoViewHeigthConstraint = photoView.heightAnchor.constraint(equalToConstant: 0)
        photoViewHeigthConstraint?.isActive = true
        
        photoViewWidthConstraint = photoView.widthAnchor.constraint(equalToConstant: 0)
        photoViewWidthConstraint?.isActive = true
        
        photoView.addInteraction(UIContextMenuInteraction(delegate: self))
        photoView.isUserInteractionEnabled = true
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        photoView.image = nil
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        let (width, height): (CGFloat, CGFloat)

        if aspectRatio.width > aspectRatio.height {
            width = contentView.bounds.width
            height = aspectRatio.height * width / aspectRatio.width
        } else {
            height = contentView.bounds.height
            width = aspectRatio.width * height / aspectRatio.height
        }

        photoViewWidthConstraint?.constant = width
        photoViewHeigthConstraint?.constant = height
    }
}

extension ProjectGridCell: UIContextMenuInteractionDelegate {
    
    func contextMenuInteraction(
        _ interaction: UIContextMenuInteraction,
        configurationForMenuAtLocation location: CGPoint
    ) -> UIContextMenuConfiguration? {
        guard imageAssetId != nil else { return nil }
        return UIContextMenuConfiguration(identifier: nil, previewProvider: nil) { _ in
            let deleteAction = UIAction(
                title: "Delete",
                image: UIImage(systemName: "trash.fill"),
                attributes: .destructive,
                handler: { [weak self] _ in self?.onDelete?() }
            )
            return UIMenu(children: [deleteAction])
        }
    }
}

#Preview(body: {
    ProjectGridCell().asPreview()
})
