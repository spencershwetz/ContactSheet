//
//  LibraryCell.swift
//  Contact Sheet
//
//  Created by Windy on 15/06/24.
//

import UIKit

final class LibraryCell: UICollectionViewCell {
    
    var onExport: (() -> Void)?
    var onDelete: (() -> Void)?
    
    static let identifier = String(describing: LibraryCell.self)
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        contentView.layer.borderWidth = 0.5
        contentView.layer.borderColor = UIColor.label.cgColor
        contentView.clipsToBounds = true
        contentView.addInteraction(UIContextMenuInteraction(delegate: self))
        contentView.isUserInteractionEnabled = true
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
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
            return UIMenu(children: [exportAction, deleteAction])
        }
    }
}
