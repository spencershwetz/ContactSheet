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
    ///private(set) var imageAssetId: String?
    private(set) var imageURL: String?

    static let identifier = String(describing: ProjectGridCell.self)
    
    private let photoView = UIImageView()
    private var photoViewWidthConstraint: NSLayoutConstraint?
    private var photoViewHeigthConstraint: NSLayoutConstraint?

    private let deleteButton = UIButton()
    private var deleteButtonWidthConstraint: NSLayoutConstraint?
    private var deleteButtonHeigthConstraint: NSLayoutConstraint?

    override init(frame: CGRect) {
        super.init(frame: frame)
        contentView.clipsToBounds = true

        photoView.layer.borderWidth = 0.5
        photoView.layer.borderColor = UIColor.label.cgColor
        photoView.clipsToBounds = true
        photoView.contentMode = .scaleAspectFill
        photoView.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(photoView)


        let configuration = UIImage.SymbolConfiguration(weight: .bold)
        deleteButton.setImage(UIImage(systemName: "x.circle.fill", withConfiguration: configuration)!.withRenderingMode(.alwaysTemplate), for: .normal)
        deleteButton.tintColor = .red

        deleteButton.translatesAutoresizingMaskIntoConstraints = false
        deleteButton.addTarget(self, action: #selector(deleteTapped), for: .touchUpInside)
        deleteButton.backgroundColor = .white
        deleteButton.layer.cornerRadius = DeviceType.xMarkSize / 2




        contentView.addSubview(deleteButton)

        NSLayoutConstraint.activate([
            photoView.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            photoView.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            deleteButton.topAnchor.constraint(equalTo: photoView.topAnchor, constant: -5),
            deleteButton.trailingAnchor.constraint(equalTo: photoView.trailingAnchor, constant: 5)
        ])

        deleteButtonWidthConstraint = deleteButton.widthAnchor.constraint(equalToConstant: 0)
        deleteButtonWidthConstraint?.isActive = true

        deleteButtonHeigthConstraint = deleteButton.heightAnchor.constraint(equalToConstant: 0)
        deleteButtonHeigthConstraint?.isActive = true

        photoViewHeigthConstraint = photoView.heightAnchor.constraint(equalToConstant: 0)
        photoViewHeigthConstraint?.isActive = true

        photoViewWidthConstraint = photoView.widthAnchor.constraint(equalToConstant: 0)
        photoViewWidthConstraint?.isActive = true
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        photoView.layer.borderColor = UIColor.label.cgColor
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        photoView.image = nil
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        var (width, height): (CGFloat, CGFloat)

        if aspectRatio.width > aspectRatio.height {
            width = contentView.bounds.width
            height = aspectRatio.height * width / aspectRatio.width
        } else {
            height = contentView.bounds.height
            width = aspectRatio.width * height / aspectRatio.height
        }

        width = max(0, width)
        height = max(0, height)

        photoViewWidthConstraint?.constant = width - 10
        photoViewHeigthConstraint?.constant = height - 10

        deleteButtonWidthConstraint?.constant = min(width * 0.5, DeviceType.xMarkSize)
        deleteButtonHeigthConstraint?.constant = min(height * 0.5, DeviceType.xMarkSize)

    }
    
    /**
     func configure(_ photo: ProjectPhoto) {
        imageAssetId = photo.assetIdentifier
        deleteButton.isHidden = imageAssetId == nil
        if let croppedImage = photo.croppedImage {
            photoView.image = croppedImage
        } else {
            guard let imageAssetId else { return }
            PhotoAssetStore.shared.getImageWithLocalId(identifier: imageAssetId) { [weak self] in
                self?.photoView.image = $0
            }
        }
    }
     */

    func configure(_ photo: CloudPhoto) {
        imageURL = photo.imageURL
        deleteButton.isHidden = imageURL == nil
        if let croppedImageURL = photo.editImageURL, let editImageURL = URL(string: croppedImageURL) {
            ImageLoader.loadImage(from: editImageURL) { [weak self] image in
                guard let self = self else { return }
                photoView.image = image
            }
        } else {
            guard let imageURL, let imagePathURL = URL(string: imageURL) else { return }

            ImageLoader.loadImage(from: imagePathURL) { [weak self] image in
                guard let self = self else { return }
                self.photoView.image = image
            }
        }
    }

    @objc
    func deleteTapped(_ sender: UIButton) {
        self.onDelete?()
    }
}

extension ProjectGridCell: UIContextMenuInteractionDelegate {
    
    func contextMenuInteraction(
        _ interaction: UIContextMenuInteraction,
        configurationForMenuAtLocation location: CGPoint
    ) -> UIContextMenuConfiguration? {
        guard imageURL != nil else { return nil }
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

private extension DeviceType {
    static var xMarkSize: CGFloat {
        DeviceType.IsDeviceIPad ? 32 : 24
    }
}
