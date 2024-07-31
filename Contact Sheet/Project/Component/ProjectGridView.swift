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

    var previousItems: [CloudPhoto] = []
    var photos: [CloudPhoto] = [] {
        didSet {

            photos.indices.forEach {
                storedPhotosForEachCell[$0] = CloudPhoto(
                    imageURL: photos[$0].imageURL,
                    editImageURL: photos[$0].editImageURL
                )
            }

            let indexes = photos.findDifferencesInURLs(array1: photos, array2: previousItems)
            if indexes.lengthDifference || previousItems.isEmpty {
                self.reloadData()
            } else {
                DispatchQueue.main.async {
                    self.reloadItems(at:
                        indexes.differingIndices.map({IndexPath(row: $0, section: 0)})
                    )
                }
            }
            previousItems = photos
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

private extension Array where Element == CloudPhoto {

    func getDifferenceIndexes(with another: Self) {
        var currentArray = self
        var anotherArray = another
        if currentArray.count != anotherArray.count {
            if currentArray.count > anotherArray.count {
                anotherArray.append(contentsOf: Array(repeating: .init(id: UUID(), imageURL: nil, editImageURL: nil), count: currentArray.count - anotherArray.count))
            } else {
                currentArray.append(contentsOf: Array(repeating: .init(id: UUID(), imageURL: nil, editImageURL: nil), count: anotherArray.count - currentArray.count))
            }
        }
    }

    func findDifferencesInURLs(
        array1: [CloudPhoto],
        array2: [CloudPhoto]
    ) -> (differingIndices: [Int], lengthDifference: Bool) {
        var differingIndices: [Int] = []
        let minCount = Swift.min(array1.count, array2.count)
        let maxCount = Swift.max(array1.count, array2.count)

        // Compare elements up to the length of the shorter array
        for index in 0..<minCount {
            let photo1 = array1[index]
            let photo2 = array2[index]

            if photo1.imageURL != photo2.imageURL || photo1.editImageURL != photo2.editImageURL {
                differingIndices.append(index)
            }
        }

        // Check if there are extra elements in the longer array
        if array1.count != array2.count {
            differingIndices.append(contentsOf: minCount..<maxCount)
        }

        // Return whether the arrays have different lengths
        let lengthDifference = array1.count != array2.count

        return (differingIndices, lengthDifference)
    }
}
