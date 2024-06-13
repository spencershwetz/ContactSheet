//
//  CreateGridView.swift
//  Contact Sheet
//
//  Created by Windy on 12/06/24.
//

import UIKit

struct ProjectImage: Hashable {
    let index: Int
    var image: UIImage?
}

final class CreateGridView: UICollectionView {
    
    private typealias Snapshot = NSDiffableDataSourceSnapshot<Section, ProjectImage>
    private typealias DataSource = UICollectionViewDiffableDataSource<Section, ProjectImage>

    private enum Section: Hashable {
        case main
    }
    
    weak var viewController: UIViewController?
    
    private lazy var diffDataSource = makeDiffDataSource()
    
    @State var totalColumn: Int = 3 {
        didSet {
            applySnapshot()
        }
    }
    
    @State var totalRow: Int = 4 {
        didSet {
            applySnapshot()
        }
    }
    
    var aspectRatio: Ratio = Ratio(width: 1, height: 1) {
        didSet {
            applySnapshot()
        }
    }

    
    private let spacingEachCell: CGFloat = 8
    private let imagePicker = ImagePicker()
    
    init() {
        let layout = UICollectionViewFlowLayout()
        layout.sectionInset = .zero
        layout.minimumLineSpacing = spacingEachCell
        layout.minimumInteritemSpacing = spacingEachCell
        super.init(frame: .zero, collectionViewLayout: layout)
        delegate = self
        dragDelegate = self
        dropDelegate = self
        dragInteractionEnabled = true
        register(CreateGridCell.self, forCellWithReuseIdentifier: CreateGridCell.identifier)
        showsVerticalScrollIndicator = false
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func makeDiffDataSource() -> DataSource {
        .init(collectionView: self) { [unowned self] collectionView, indexPath, item in
            let cell = collectionView.dequeueReusableCell(
                withReuseIdentifier: CreateGridCell.identifier,
                for: indexPath
            ) as! CreateGridCell
            cell.backgroundColor = .red.withAlphaComponent(0.3)
            cell.aspectRatio = aspectRatio
            cell.image = item.image
            cell.textLabel.font = .preferredFont(forTextStyle: .headline)
            cell.textLabel.text = "\(item.index)"
            return cell
        }
    }
    
    private func applySnapshot() {
        var snapshot = Snapshot()
        snapshot.appendSections([.main])
        snapshot.appendItems((0..<totalColumn * totalRow).map { ProjectImage(index: $0, image: nil) })
        diffDataSource.apply(snapshot)
    }
}

extension CreateGridView: UICollectionViewDragDelegate {

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

extension CreateGridView: UICollectionViewDropDelegate {

    func collectionView(
        _ collectionView: UICollectionView,
        performDropWith coordinator: UICollectionViewDropCoordinator
    ) {
        guard let destinationIndexPath = coordinator.destinationIndexPath else { return }

        var items = diffDataSource.snapshot().itemIdentifiers

        coordinator.items.forEach { item in
            guard let sourceIndexPath = item.sourceIndexPath else { return }
            let movedItem = items.remove(at: sourceIndexPath.item)
            items.insert(movedItem, at: destinationIndexPath.item)

            var snapshot = Snapshot()
            snapshot.appendSections([.main])
            snapshot.appendItems(items)
            diffDataSource.apply(snapshot)

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


extension CreateGridView: UICollectionViewDelegate {
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let cell = collectionView.cellForItem(at: indexPath) as! CreateGridCell
        if cell.image == nil {
            imagePicker.show(on: viewController, onPickImage: { [weak self] in
                guard let self else { return }
                
                var newItems = diffDataSource.snapshot().itemIdentifiers
                newItems[indexPath.item].image = $0
                
                var newSnapshot = Snapshot()
                newSnapshot.appendSections([.main])
                newSnapshot.appendItems(newItems, toSection: .main)
                diffDataSource.apply(newSnapshot)
            })
        }
    }
}

extension CreateGridView: UICollectionViewDelegateFlowLayout {
    func collectionView(
        _ collectionView: UICollectionView,
        layout collectionViewLayout: UICollectionViewLayout,
        sizeForItemAt indexPath: IndexPath
    ) -> CGSize {
        let totalSpacing = CGFloat(totalColumn - 1) * spacingEachCell
        let totalWidth = collectionView.bounds.width - totalSpacing
        
        return CGSize(
            width: totalWidth / CGFloat(totalColumn),
            height: totalWidth / CGFloat(totalColumn)
        )
    }
}
