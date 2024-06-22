//
//  LibraryThumbnailContentView.swift
//  Contact Sheet
//
//  Created by Windy on 22/06/24.
//

import UIKit

final class LibraryThumbnailContentView: UIView {
    
    private let spacingEachCell: CGFloat = 4
    private let sectionInset = UIEdgeInsets(top: 4, left: 4, bottom: 4, right: 4)
    
    var images: [String?] = [] {
        didSet {
            collectionView.reloadData()
        }
    }
    
    private lazy var collectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.sectionInset = sectionInset
        layout.minimumInteritemSpacing = spacingEachCell
        layout.minimumLineSpacing = spacingEachCell

        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.isUserInteractionEnabled = false
        collectionView.isScrollEnabled = false
        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.register(LibraryThumbnailCell.self, forCellWithReuseIdentifier: LibraryThumbnailCell.identifier)
        return collectionView
    }()
    
    init() {
        super.init(frame: .zero)
        
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        addSubview(collectionView)
        
        NSLayoutConstraint.activate([
            collectionView.topAnchor.constraint(equalTo: topAnchor),
            collectionView.bottomAnchor.constraint(equalTo: bottomAnchor),
            collectionView.leadingAnchor.constraint(equalTo: leadingAnchor),
            collectionView.trailingAnchor.constraint(equalTo: trailingAnchor),
        ])
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

extension LibraryThumbnailContentView: UICollectionViewDelegateFlowLayout {
    func collectionView(
        _ collectionView: UICollectionView,
        layout collectionViewLayout: UICollectionViewLayout,
        sizeForItemAt indexPath: IndexPath
    ) -> CGSize {
        let horizontalGridCount: CGFloat = 2
        let verticalGridCount: CGFloat = 4
        
        let horizontalMargin = sectionInset.left + sectionInset.right
        let verticalMargin = sectionInset.top + sectionInset.bottom

        let totalHorizontalSpacing = ((horizontalGridCount - 1) * spacingEachCell)
        let totalVerticalSpacing = ((verticalGridCount - 1) * spacingEachCell)

        let totalWidth = collectionView.bounds.width - totalHorizontalSpacing - horizontalMargin
        let totalHeight = collectionView.bounds.height - totalVerticalSpacing - verticalMargin

        return CGSize(
            width: totalWidth / horizontalGridCount,
            height: totalHeight / verticalGridCount
        )
    }
}

extension LibraryThumbnailContentView: UICollectionViewDataSource {

    func collectionView(
        _ collectionView: UICollectionView,
        numberOfItemsInSection section: Int
    ) -> Int {
        images.count
    }

    func collectionView(
        _ collectionView: UICollectionView,
        cellForItemAt indexPath: IndexPath
    ) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(
            withReuseIdentifier: LibraryThumbnailCell.identifier,
            for: indexPath
        ) as! LibraryThumbnailCell
        cell.imageURL = images[indexPath.item]
        return cell
    }
}
