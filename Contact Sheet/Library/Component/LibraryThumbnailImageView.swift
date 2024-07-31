//
//  LibraryThumbnailCell.swift
//  Contact Sheet
//
//  Created by Windy on 22/06/24.
//

import UIKit

final class LibraryThumbnailImageView: UIView {
    
    static let identifier = String(describing: LibraryThumbnailImageView.self)
    
    private let imageView = UIImageView()
    
    init() {
        super.init(frame: .zero)
        imageView.clipsToBounds = true
        imageView.contentMode = .scaleAspectFill
        imageView.layer.borderWidth = 0.25
        imageView.layer.borderColor = UIColor.label.cgColor
        imageView.translatesAutoresizingMaskIntoConstraints = false
        addSubview(imageView)
        
        NSLayoutConstraint.activate([
            imageView.topAnchor.constraint(equalTo: topAnchor),
            imageView.bottomAnchor.constraint(equalTo: bottomAnchor),
            imageView.leadingAnchor.constraint(equalTo: leadingAnchor),
            imageView.trailingAnchor.constraint(equalTo: trailingAnchor),
        ])
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        imageView.layer.borderColor = UIColor.label.cgColor
    }
    
    @discardableResult
    func imageURL(_ imageURL: String?, _ editedImageURL: String?) -> Self {
        guard let imageURL, let imagePathURL = URL(string: imageURL) else { return self }
        if let editedImageURL = editedImageURL, let editedImagePathURL = URL(string: editedImageURL) {
            ImageLoader.loadImage(from: editedImagePathURL) { [weak self] image in
                guard let self = self else { return }
                DispatchQueue.main.async {
                    self.imageView.image = image
                }
            }
        } else {
            ImageLoader.loadImage(from: imagePathURL) { [weak self] image in
                guard let self = self else { return }
                DispatchQueue.main.async {
                    self.imageView.image = image
                }
            }
        }
//        PhotoAssetStore.shared.getImageWithLocalId(identifier: imageURL) { [weak self] in
//            self?.imageView.image = $0
//        }
        return self
    }
    
    @discardableResult
    func aspectRatio(_ aspectRatio: CGFloat) -> Self {
        heightAnchor.constraint(equalTo: widthAnchor, multiplier: aspectRatio).isActive = true
        return self
    }
}
