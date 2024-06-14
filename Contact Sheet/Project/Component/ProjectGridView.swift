//
//  CreateGridView.swift
//  Contact Sheet
//
//  Created by Windy on 12/06/24.
//

import UIKit

final class ProjectGridView: UICollectionView {
    
    private typealias Snapshot = NSDiffableDataSourceSnapshot<Section, ProjectPhoto>
    private typealias DataSource = UICollectionViewDiffableDataSource<Section, ProjectPhoto>

    private enum Section: Hashable {
        case main
    }
    
    weak var viewController: UIViewController?
    
    private lazy var diffDataSource = makeDiffDataSource()
    
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
            forceReloadItems()
        }
    }

    var photos: [ProjectPhoto] = [] {
        didSet {
            applySnapshot(items: photos)
        }
    }
    
    private let spacingEachCell: CGFloat = 8
    private let imagePicker = ImagePicker()
    
    private let layout = UICollectionViewFlowLayout()

    init() {
        layout.sectionInset = .init(top: 0, left: 0, bottom: 16, right: 0)
        layout.minimumLineSpacing = spacingEachCell
        layout.minimumInteritemSpacing = spacingEachCell
        super.init(frame: .zero, collectionViewLayout: layout)
        delegate = self
        dragDelegate = self
        dropDelegate = self
        dragInteractionEnabled = true
        register(ProjectGridCell.self, forCellWithReuseIdentifier: ProjectGridCell.identifier)
        showsVerticalScrollIndicator = false
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func invalidateLayout() {
        layout.invalidateLayout()
    }
    
    private func makeDiffDataSource() -> DataSource {
        .init(collectionView: self) { [unowned self] collectionView, indexPath, item in
            let cell = collectionView.dequeueReusableCell(
                withReuseIdentifier: ProjectGridCell.identifier,
                for: indexPath
            ) as! ProjectGridCell
            cell.aspectRatio = aspectRatio
            cell.image = item.image
            cell.onDelete = { [weak self] in
                self?.photos = self?.photos.removeImage(at: indexPath.item) ?? []
            }
            return cell
        }
    }
    
    private func applySnapshot(items: [ProjectPhoto], animatingDifferences: Bool = true) {
        var snapshot = Snapshot()
        snapshot.appendSections([.main])
        snapshot.appendItems(items)
        diffDataSource.apply(snapshot, animatingDifferences: animatingDifferences)
    }
    
    private func forceReloadItems() {
        let currentItems = photos
        applySnapshot(items: [], animatingDifferences: false)
        applySnapshot(items: currentItems, animatingDifferences: false)
    }
    
    private func updateItems() {
        let maxItems = totalColumns * totalRows

        guard maxItems > 0 else { return }
        
        if photos.count < maxItems {
            let totalItemToAppend = maxItems - photos.count
            let newItemsToAppend = (0..<totalItemToAppend)
                .map { _ in ProjectPhoto(image: nil) }
            photos = photos + newItemsToAppend
        } else {
            let totalItemsToRemove = photos.count - maxItems
            (0..<totalItemsToRemove).forEach { _ in
                photos.removeLast()
            }
        }
    }
}

extension ProjectGridView: UICollectionViewDragDelegate {

    func collectionView(
        _ collectionView: UICollectionView,
        itemsForBeginning session: UIDragSession,
        at indexPath: IndexPath
    ) -> [UIDragItem] {
        let item = diffDataSource.itemIdentifier(for: indexPath)
        let itemProvider = NSItemProvider(object: "\(String(describing: item))" as NSString)
        let dragItem = UIDragItem(itemProvider: itemProvider)
        dragItem.localObject = item
        return [dragItem]
    }
}

extension ProjectGridView: UICollectionViewDropDelegate {

    func collectionView(
        _ collectionView: UICollectionView,
        performDropWith coordinator: UICollectionViewDropCoordinator
    ) {
        guard let destinationIndexPath = coordinator.destinationIndexPath else { return }
        coordinator.items.forEach { item in
            guard let sourceIndex = item.sourceIndexPath else { return }
            photos = photos.movedItem(at: sourceIndex.item, to: destinationIndexPath.item)
            coordinator.drop(item.dragItem, toItemAt: destinationIndexPath)
        }
    }

    func collectionView(
        _ collectionView: UICollectionView,
        canHandle session: UIDropSession
    ) -> Bool {
        return session.canLoadObjects(ofClass: NSString.self)
    }

    func collectionView(
        _ collectionView: UICollectionView,
        dropSessionDidUpdate session: UIDropSession,
        withDestinationIndexPath destinationIndexPath: IndexPath?
    ) -> UICollectionViewDropProposal {
        return UICollectionViewDropProposal(operation: .move, intent: .insertAtDestinationIndexPath)
    }
}


extension ProjectGridView: UICollectionViewDelegate {
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let cell = collectionView.cellForItem(at: indexPath) as! ProjectGridCell
        if cell.image == nil {
            imagePicker.show(on: viewController, onPickImage: { [weak self] in
                guard let self else { return }
                photos = photos.addImage($0, at: indexPath.item)
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
