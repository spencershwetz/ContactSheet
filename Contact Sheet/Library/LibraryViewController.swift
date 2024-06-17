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

    private var projects: [Project] = [] {
        didSet {
            applySnapshot(items: projects)
        }
    }
    
    private var createButtonBarItem: UIBarButtonItem!
    private var mergeButtonBarItem: UIBarButtonItem!
    private var selectButtonBarItem: UIBarButtonItem!

    private var selectedProject: Project? = nil
    private let store = ProjectStore.shared
    private let gridItemCount: CGFloat = 3
    private let spacingEachCell: CGFloat = 16
    private let sectionInset = UIEdgeInsets(top: 16, left: 16, bottom: 16, right: 16)

    private var isSelectionEnabled: Bool = false
    private var selectedProjects: [(Project, Int)] = [] {
        didSet {
            if selectedProjects.count > 1 {
                addMergeMenuBarItem()
            } else {
                removeMergeMenuBarItem()
            }
        }
    }

    private lazy var collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
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
        projects = store.get()
    }
    
    private func makeDiffDataSource() -> DataSource {
        .init(collectionView: collectionView) { [unowned self] collectionView, indexPath, item in
            let cell = collectionView.dequeueReusableCell(
                withReuseIdentifier: LibraryCell.identifier,
                for: indexPath
            ) as! LibraryCell
            cell.onDelete = { [unowned self] in
                store.delete(id: projects[indexPath.item].id)
                projects.remove(at: indexPath.item)
            }
            cell.onExport = { [unowned self] in
                navigationController?.pushViewController(ExportViewController(), animated: true)
            }

            cell.onRename = { [unowned self] in
                selectedProject = projects[indexPath.item]
                showRenameAlert()
            }
            cell.isEnableSelection = isSelectionEnabled
            cell.isImageSelected = selectedProjects.contains(where: {$0.0.id == projects[indexPath.item].id})
            if let photoId: String? = projects[indexPath.item].photos.first(where: {$0 != nil}), let photoId = photoId  {
                PhotoAssetStore.shared.getImageWithLocalId(identifier: photoId) { image in
                    cell.image = image
                }
            }
            cell.title = projects[indexPath.item].title
        

            return cell
        }
    }
    
    private func applySnapshot(items: [Project]) {
        var snapshot = Snapshot()
        snapshot.appendSections([.main])
        snapshot.appendItems(items)
        diffDataSource.apply(snapshot)
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
        createButtonBarItem = UIBarButtonItem(
            barButtonSystemItem: .add,
            target: self,
            action: #selector(handleCreateProject)
        )

        selectButtonBarItem = UIBarButtonItem(
            title: "Select",
            style: .plain,
            target: self,
            action: #selector(handleSelectAction)
        )

        mergeButtonBarItem = UIBarButtonItem(
            title: "Merge",
            style: .plain,
            target: self,
            action: #selector(handleMergeProjects)
        )

        navigationItem.rightBarButtonItems = [
            createButtonBarItem,
            selectButtonBarItem
        ]
    }

    @objc
    private func handleSelectAction() {
        isSelectionEnabled.toggle()
        if isSelectionEnabled {
            selectedProjects = []
        }
        if let lastItem = self.navigationItem.rightBarButtonItems?.last {
            lastItem.title = isSelectionEnabled == false ? "Select" : "Cancel"
        }

        self.collectionView.reloadData()
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
        var newProject = Project(
            id: UUID(),
            pageSizeRatio: .init(width: 1, height: 1),
            photoAspectRatio: .init(width: 1, height: 1),
            totalRows: 0,
            totalColumns: 0,
            photos: [],
            title: "Untitled Project"
        )
        store.create(id: newProject.id)
        
        let projects: [Project] = selectedProjects.map({$0.0})
        let photos: [String] = projects.map({$0.photos.compactMap({$0})}).reduce([], +)

        newProject.photos = photos
        newProject.totalRows = Int(photos.count / 4) + 1
        newProject.totalColumns = 4
        store.update(project: newProject)
        self.projects.append(newProject)
        selectedProjects = []
        handleSelectAction()
    }

    func addMergeMenuBarItem() {
        navigationItem.rightBarButtonItems = [
            createButtonBarItem,
            selectButtonBarItem,
            mergeButtonBarItem,
        ]
    }

    func removeMergeMenuBarItem() {
        navigationItem.rightBarButtonItems = [
            createButtonBarItem,
            selectButtonBarItem
        ]

    }

}

extension LibraryViewController: UICollectionViewDelegate {
    
    func collectionView(
        _ collectionView: UICollectionView,
        didSelectItemAt indexPath: IndexPath
    ) {
        if isSelectionEnabled {
            if let idx = self.selectedProjects.firstIndex(where: {$0.1 == indexPath.item}) {
                selectedProjects.remove(at: idx)
            } else {
                selectedProjects.append((projects[indexPath.item], indexPath.item))
            }
            collectionView.reloadData()

        } else {
            let project = projects[indexPath.item]
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
        
        return CGSize(
            width: totalWidth / gridItemCount,
            height: totalWidth / gridItemCount + 50
        )
    }
}

extension LibraryViewController {
    private func showRenameAlert() {
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
        ) { [unowned alert, weak self] _ in
            guard
                let nameText = alert.textFields![0].text, !(nameText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
            else {
                return
            }
            self?.handleRenameProjectAction(with: nameText)
        }

        alert.addAction(submitAction)
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        present(alert, animated: true, completion: nil)
    }

    func handleRenameProjectAction(with title: String) {
        selectedProject?.title = title
        store.update(project: selectedProject!)
        collectionView.reloadData()
        if let firstIdx = projects.firstIndex(where: {$0.id == selectedProject?.id}) {
            projects[firstIdx].title = selectedProject?.title ?? ""
        }
        selectedProject = nil
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
            photoIds: project.photos,
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
            photoIds: [],
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
