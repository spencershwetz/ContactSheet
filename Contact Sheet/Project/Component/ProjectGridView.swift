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

    var photos: [CloudPhoto] = [] {
        didSet {
            photos.indices.forEach {
                storedPhotosForEachCell[$0] = CloudPhoto(
                    imageURL: photos[$0].imageURL,
                    editImageURL: photos[$0].editImageURL
                )
            }
            reloadData()
        }
    }
    
    private var storedPhotosForEachCell: [Int: CloudPhoto] = [:]

    private let spacingEachCell: CGFloat = 0
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
                    CloudPhoto(
                        imageURL: storedPhotosForEachCell[$0]?.imageURL,
                        editImageURL: storedPhotosForEachCell[$0]?.editImageURL
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
        if let imageURL = cell.imageURL, let imageURL = URL(string: imageURL) {
            ImageLoader.loadImage(from: imageURL) { [weak self] image in
                guard let self, let image else { return }
                cropPresenter.show(
                    image: image,
                    ratio: aspectRatio,
                    onCropped: { [weak self] in
                        guard let self else { return }
                        CloudDataManager.sharedInstance.saveImage(image: $0) { [weak self] url in
                            guard let self = self else { return }
                            if let url {
                                photos = photos.updatedCroppedImage(url.absoluteString, at: indexPath.item)
                            }
                        }
                    }
                )
            }
        } else {
            imagePicker.show(on: viewController, onPickImages: { [weak self] images in
                guard let self else { return }
                CloudDataManager.sharedInstance.saveMultipleImages(images: images) { urls in
                    let (addedPhotos, addedRows) = self.photos.addImages(urls.compactMap({$0?.absoluteString}), from: indexPath.item, totalColumns: self.totalColumns)
                    self.photos = addedPhotos
                    self.totalRows += addedRows
                }
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
