//
//  ViewController.swift
//  Contact Sheet
//
//  Created by Windy on 11/06/24.
//

import UIKit

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
    
    private let store = ProjectStore.shared
    private let gridItemCount: CGFloat = 3
    private let spacingEachCell: CGFloat = 16
    private let sectionInset = UIEdgeInsets(top: 0, left: 16, bottom: 16, right: 16)
    
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
        navigationItem.rightBarButtonItems = [
            UIBarButtonItem(
                barButtonSystemItem: .add,
                target: self,
                action: #selector(handleCreateProject)
            ),
            UIBarButtonItem(
                title: "Select",
                style: .plain,
                target: self,
                action: #selector(handleSelectAction)
            )
        ]
    }

    @objc
    private func handleSelectAction() {
        
    }
    
    @objc
    private func handleCreateProject() {
        let newProjectID = UUID()
        store.create(id: newProjectID)
        
        let vc = ProjectViewController(config: .initialConfig(id: newProjectID))
        navigationController?.pushViewController(vc, animated: true)
    }
}

extension LibraryViewController: UICollectionViewDelegate {
    
    func collectionView(
        _ collectionView: UICollectionView,
        didSelectItemAt indexPath: IndexPath
    ) {
        let project = projects[indexPath.item]
        let vc = ProjectViewController(config: .init(project: project))
        navigationController?.pushViewController(vc, animated: true)
    }
}

extension LibraryViewController: UICollectionViewDelegateFlowLayout {
    
    func collectionView(
        _ collectionView: UICollectionView,
        layout collectionViewLayout: UICollectionViewLayout,
        sizeForItemAt indexPath: IndexPath
    ) -> CGSize {
        let horizontalMargin = sectionInset.left + sectionInset.right
        let totalSpacing = (gridItemCount - 1) * spacingEachCell
        let totalWidth = collectionView.bounds.width - totalSpacing - horizontalMargin
        
        return CGSize(
            width: totalWidth / gridItemCount,
            height: totalWidth / gridItemCount
        )
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
            photoURLs: project.photos,
            totalRows: project.totalRows,
            totalColumns: project.totalColumns
        )
    }
    
    static func initialConfig(id: UUID) -> Self {
        ProjectViewController.Config(
            id: id,
            pageSizeRatio: .init(width: 16, height: 9),
            photoAspectRatio: .init(width: 1, height: 1),
            photoURLs: [],
            totalRows: 4,
            totalColumns: 3
        )
    }
}
