//
//  CreateGridView.swift
//  Contact Sheet
//
//  Created by Windy on 12/06/24.
//

import UIKit
import Mantis

final class ProjectGridView: UICollectionView {

    weak var viewController: UIViewController?
    
    @State var totalColumns: Int = 0 {
        didSet {
            updateItems()
        }
    }
    
    @State var totalRows: Int = 0 {
        didSet {
            updateItems()
        }
    }
    
    var aspectRatio: Ratio = .random {
        didSet {
            reloadData()
        }
    }

    var photos: [ProjectPhoto] = [] {
        didSet {
            photos.indices.forEach {
                storedPhotosForEachCell[$0] = ProjectPhoto(
                    assetIdentifier: photos[$0].assetIdentifier,
                    croppedImage: photos[$0].croppedImage
                )
            }
            reloadData()
        }
    }
    
    private var storedPhotosForEachCell: [Int: ProjectPhoto] = [:]

    private let spacingEachCell: CGFloat = 8
    private let imagePicker = MultiImagePicker()
    private lazy var cropPresenter = CropPresenter(viewController: viewController)

    private let layout = UICollectionViewFlowLayout()

    init() {
        layout.sectionInset = .init(top: 0, left: 0, bottom: 16, right: 0)
        layout.minimumLineSpacing = spacingEachCell
        layout.minimumInteritemSpacing = spacingEachCell
        super.init(frame: .zero, collectionViewLayout: layout)

        clipsToBounds = true
        delegate = self
        dataSource = self
        register(ProjectGridCell.self, forCellWithReuseIdentifier: ProjectGridCell.identifier)
        showsVerticalScrollIndicator = false

        let longPressGesture = UILongPressGestureRecognizer(
            target: self,
            action: #selector(handleLongGesture(_:))
        )
        longPressGesture.minimumPressDuration = 0.1
        addGestureRecognizer(longPressGesture)
    }
    
    @objc
    private func handleLongGesture(_ gesture: UILongPressGestureRecognizer) {
        switch gesture.state {
        case .began:
            guard let selectedIndexPath = indexPathForItem(at: gesture.location(in: self))
            else { break }
            beginInteractiveMovementForItem(at: selectedIndexPath)
        case .changed:
            updateInteractiveMovementTargetPosition(gesture.location(in: gesture.view!))
        case .ended:
            endInteractiveMovement()
        default:
            cancelInteractiveMovement()
        }
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func invalidateLayout() {
        layout.invalidateLayout()
    }
    
    private func updateItems() {
        let maxItems = totalColumns * totalRows

        guard maxItems > 0 else { return }
        
        if photos.count < maxItems {
            let newItemsToAppend = (photos.count..<maxItems)
                .map {
                    ProjectPhoto(
                        assetIdentifier: storedPhotosForEachCell[$0]?.assetIdentifier,
                        croppedImage: storedPhotosForEachCell[$0]?.croppedImage
                    )
                }
            photos = photos + newItemsToAppend
        } else {
            let totalItemsToRemove = photos.count - maxItems
            (0..<totalItemsToRemove).forEach { _ in
                photos.removeLast()
            }
        }
    }
}

extension ProjectGridView: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        photos.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(
            withReuseIdentifier: ProjectGridCell.identifier,
            for: indexPath
        ) as! ProjectGridCell
        cell.aspectRatio = aspectRatio
        cell.configure(photos[indexPath.item])
        cell.onDelete = { [weak self] in
            self?.photos = self?.photos.removeImage(at: indexPath.item) ?? []
        }
        return cell
    }

    func collectionView(
        _ collectionView: UICollectionView,
        moveItemAt sourceIndexPath: IndexPath,
        to destinationIndexPath: IndexPath
    ) {
        photos = photos.movedItem(at: sourceIndexPath.item, to: destinationIndexPath.item)
    }
    
}

extension ProjectGridView: UICollectionViewDelegate {
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let cell = collectionView.cellForItem(at: indexPath) as! ProjectGridCell
        if let imageAssetId = cell.imageAssetId {
            PhotoAssetStore.shared
                .getImageWithLocalId(identifier: imageAssetId) { [weak self] image in
                    guard let self, let image else { return }
                    cropPresenter.show(
                        image: image,
                        ratio: aspectRatio,
                        onCropped: { [weak self] in
                            guard let self else { return }
                            photos = photos.updatedCroppedImage($0, at: indexPath.item)
                        }
                    )
                }
        } else {
            imagePicker.show(on: viewController, onPickImages: { [weak self] images in
                guard let self else { return }
                
                let (addedPhotos, addedRows) = photos.addImages(images, from: indexPath.item, totalColumns: totalColumns)
                photos = addedPhotos
                totalRows += addedRows
            })
        }
    }
}

extension ProjectGridView: UICollectionViewDelegateFlowLayout {
    func collectionView(
        _ collectionView: UICollectionView,
        layout collectionViewLayout: UICollectionViewLayout,
        sizeForItemAt indexPath: IndexPath
    ) -> CGSize {
        let totalSpacing = CGFloat(totalColumns - 1) * spacingEachCell
        let totalWidth = collectionView.bounds.width - totalSpacing
        
        return CGSize(
            width: totalWidth / CGFloat(totalColumns),
            height: totalWidth / CGFloat(totalColumns)
        )
    }
}
