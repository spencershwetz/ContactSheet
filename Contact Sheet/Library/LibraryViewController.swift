//
//  ViewController.swift
//  Contact Sheet
//
//  Created by Windy on 11/06/24.
//

import UIKit
import SwiftUI

final class LibraryViewController: UIViewController {
    
    private typealias Snapshot = NSDiffableDataSourceSnapshot<Section, Project>
    private typealias DataSource = UICollectionViewDiffableDataSource<Section, Project>

    private enum Section: Hashable {
        case main
    }

    private lazy var createButtonBarItem = UIBarButtonItem(
        barButtonSystemItem: .add,
        target: self,
        action: #selector(handleCreateProject)
    )
    private lazy var mergeButtonBarItem = UIBarButtonItem(
        title: "Merge",
        style: .plain,
        target: self,
        action: #selector(handleMergeProjects)
    )
    private lazy var selectButtonBarItem = UIBarButtonItem(
        title: "Select",
        style: .plain,
        target: self,
        action: #selector(handleSelectAction)
    )
    private lazy var settingButtonBarItem = UIBarButtonItem(
        image: UIImage(systemName: "gear"),
        style: .plain,
        target: self,
        action: #selector(handleSettingAction)
    )

    private let store = ProjectStore.shared
    private let gridItemCount: CGFloat = 3
    private let spacingEachCell: CGFloat = 16
    private let sectionInset = UIEdgeInsets(top: 16, left: 16, bottom: 16, right: 16)

    private var isSelectionEnabled: Bool = false
    private var selectedProjects: [Project] = [] {
        didSet {
            if selectedProjects.count > 1 {
                mergeButtonBarItem.isHidden = false
            } else {
                mergeButtonBarItem.isHidden = true
            }
        }
    }

    private lazy var collectionView: UICollectionView = {
        let layout = AlignedCollectionViewFlowLayout(verticalAlignment: .top)
        layout.sectionInset = sectionInset
        layout.minimumLineSpacing = spacingEachCell
        layout.minimumInteritemSpacing = spacingEachCell
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        return collectionView
    }()
    
    private lazy var diffDataSource = makeDiffDataSource()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        setupNavigationBar()
        setupCollectionView()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        reloadData()
    }
    
    private func reloadData() {
        applySnapshot(items: store.get())
    }
    
    private func redrawCells() {
        let items = diffDataSource.snapshot().itemIdentifiers
        applySnapshot(items: [], animatingDifferences: false)
        applySnapshot(items: items, animatingDifferences: false)
    }
    
    private func appendProject(_ project: Project) {
        var snapshot = diffDataSource.snapshot()
        snapshot.appendItems([project])
        diffDataSource.apply(snapshot)
    }
    
    private func deleteProject(_ project: Project) {
        var snapshot = diffDataSource.snapshot()
        snapshot.deleteItems([project])
        diffDataSource.apply(snapshot)
    }
    
    private func makeDiffDataSource() -> DataSource {
        .init(collectionView: collectionView) { [unowned self] collectionView, indexPath, project in
            let cell = collectionView.dequeueReusableCell(
                withReuseIdentifier: LibraryCell.identifier,
                for: indexPath
            ) as! LibraryCell
            cell.onDelete = { [unowned self] in
                store.delete(id: project.id)
                deleteProject(project)
            }
            cell.onExport = { [unowned self] in
                navigationController?.pushViewController(ExportViewController(project: project), animated: true)
            }
            cell.onRename = { [unowned self] in
                showRenameProjectAlert(project)
            }
            cell.isEnableSelection = isSelectionEnabled
            cell.images = Array(project.photos.map(\.assetIdentifier).prefix(8))
            cell.title = project.title
        
            return cell
        }
    }
    
    private func applySnapshot(items: [Project], animatingDifferences: Bool = true) {
        var snapshot = Snapshot()
        snapshot.appendSections([.main])
        snapshot.appendItems(items)
        diffDataSource.apply(snapshot, animatingDifferences: animatingDifferences)
    }
    
    private func setupCollectionView() {
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        collectionView.delegate = self
        collectionView.register(
            LibraryCell.self,
            forCellWithReuseIdentifier: LibraryCell.identifier
        )
        view.addSubview(collectionView)
        NSLayoutConstraint.activate([
            collectionView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            collectionView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
            collectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            collectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
        ])
    }
    
    private func setupNavigationBar() {
        navigationItem.rightBarButtonItems = [
            settingButtonBarItem,
            createButtonBarItem,
            selectButtonBarItem,
            mergeButtonBarItem

        ]
    }

    @objc
    private func handleSelectAction() {
        isSelectionEnabled.toggle()
        if isSelectionEnabled {
            selectedProjects = []
        }
        selectButtonBarItem.title = isSelectionEnabled ? "Cancel" : "Select"
        redrawCells()
        settingButtonBarItem.isHidden = isSelectionEnabled
        createButtonBarItem.isHidden = isSelectionEnabled
    }
    
    @objc
    private func handleCreateProject() {
        let newProjectID = UUID()
        store.create(id: newProjectID)
        
        let vc = ProjectViewController(config: .initialConfig(id: newProjectID))
        navigationController?.pushViewController(vc, animated: true)
    }

    @objc
    private func handleMergeProjects() {
        let photos = selectedProjects.map { $0.photos.compactMap { $0 } }.reduce([], +)

        let newProject = Project(
            id: UUID(),
            pageSizeRatio: .init(width: 16, height: 9),
            photoAspectRatio: .init(width: 1, height: 1),
            totalRows: Int(photos.count / 4) + 1,
            totalColumns: 4,
            photos: photos,
            title: "Untitled Project"
        )

        store.create(newProject)
        appendProject(newProject)
        selectedProjects = []
        handleSelectAction()
    }
    @objc
    private func handleSettingAction() {
        let setting = SettingViewController()
        present(UINavigationController(rootViewController: setting), animated: true)
    }
}

extension LibraryViewController: UICollectionViewDelegate {
    
    func collectionView(
        _ collectionView: UICollectionView,
        didSelectItemAt indexPath: IndexPath
    ) {
        guard
            let project = diffDataSource.itemIdentifier(for: indexPath),
            let cell = collectionView.cellForItem(at: indexPath) as? LibraryCell
        else {
            return
        }
        
        if isSelectionEnabled {
            if cell.isImageSelected {
                selectedProjects.removeAll(where: { $0.id == project.id })
            } else {
                selectedProjects.append(project)
            }
            cell.isImageSelected.toggle()
        } else {
            let vc = ProjectViewController(config: .init(project: project))
            navigationController?.pushViewController(vc, animated: true)
        }
    }
}

extension LibraryViewController: UICollectionViewDelegateFlowLayout {
    
    func collectionView(
        _ collectionView: UICollectionView,
        layout collectionViewLayout: UICollectionViewLayout,
        sizeForItemAt indexPath: IndexPath
    ) -> CGSize {
        let horizontalMargin = sectionInset.left + sectionInset.right
        let totalSpacing = ((gridItemCount - 1) * spacingEachCell) + 0.1
        let totalWidth = collectionView.bounds.width - totalSpacing - horizontalMargin
        
        let width = totalWidth / gridItemCount
        
        return CGSize(
            width: width,
            height: calculateHeight(
                width: width,
                title: diffDataSource.itemIdentifier(for: indexPath)?.title
            )
        )
    }
    
    private func calculateHeight(width: CGFloat, title: String?) -> CGFloat {
        let cell = LibraryCell()
        let preferredSize = CGSize(
            width: width,
            height: UIView.layoutFittingCompressedSize.height
        )

        cell.title = title
        
        let size = cell.systemLayoutSizeFitting(
            preferredSize,
            withHorizontalFittingPriority: .required,
            verticalFittingPriority: .fittingSizeLevel
        )
        
        return size.height
    }
}

extension LibraryViewController {
    private func showRenameProjectAlert(_ project: Project) {
        let alert = UIAlertController(
            title: "Project Name",
            message: "Please enter project name",
            preferredStyle: .alert
        )

        alert.addTextField { textField in
            textField.placeholder = "Name"
            textField.keyboardType = .default
        }

        let submitAction = UIAlertAction(
            title: "Okay",
            style: .default
        ) { [unowned alert, unowned self] _ in
            guard
                let nameText = alert.textFields![0].text,
                !(nameText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
            else {
                return
            }

            var project = project
            project.title = nameText
            store.update(project: project)
            reloadData()
        }

        alert.addAction(submitAction)
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        present(alert, animated: true, completion: nil)
    }
}

private extension ProjectViewController.Config {
 
    init(project: Project) {
        self.init(
            id: project.id,
            pageSizeRatio: .init(
                width: project.pageSizeRatio.width,
                height: project.pageSizeRatio.height
            ),
            photoAspectRatio: .init(
                width: project.photoAspectRatio.width,
                height: project.photoAspectRatio.height),
            photos: project.photos.map { ProjectPhoto(assetIdentifier: $0.assetIdentifier, croppedImage: $0.croppedImage)},
            totalRows: project.totalRows,
            totalColumns: project.totalColumns,
            title: project.title
        )
    }
    
    static func initialConfig(id: UUID) -> Self {
        ProjectViewController.Config(
            id: id,
            pageSizeRatio: .init(width: 16, height: 9),
            photoAspectRatio: .init(width: 1, height: 1),
            photos: [],
            totalRows: 4,
            totalColumns: 3,
            title: "Untitled Project"
        )
    }
}

#Preview {
    return makeLibraryViewController().asPreview()

    func makeLibraryViewController() -> UIViewController {
        let vc = LibraryViewController()
        let navigationController = UINavigationController(rootViewController: vc)
        navigationController.navigationBar.prefersLargeTitles = true
        vc.title = "Library"
        return navigationController
    }

}
