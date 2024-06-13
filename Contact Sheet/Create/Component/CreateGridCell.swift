//
//  CreateGridCell.swift
//  Contact Sheet
//
//  Created by Windy on 12/06/24.
//

import UIKit

final class CreateGridCell: UICollectionViewCell {
    
    var aspectRatio = Ratio(width: 1, height: 1)
    var image: UIImage? {
        didSet {
            photoView.image = image
        }
    }
    
    let textLabel = UILabel()
    static let identifier = String(describing: CreateGridCell.self)
    
    private let photoView = UIImageView()
    
    private var photoViewWidthConstraint: NSLayoutConstraint?
    private var photoViewHeigthConstraint: NSLayoutConstraint?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        contentView.clipsToBounds = true
        
        
        
        photoView.backgroundColor = .blue.withAlphaComponent(0.5)
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
        
        contentView.addSubview(textLabel)
        textLabel.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            textLabel.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            textLabel.centerXAnchor.constraint(equalTo: contentView.centerXAnchor)
        ])
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
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
