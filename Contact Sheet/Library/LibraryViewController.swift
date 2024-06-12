//
//  ViewController.swift
//  Contact Sheet
//
//  Created by Windy on 11/06/24.
//

import UIKit

final class LibraryViewController: UIViewController {

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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        setupNavigationBar()
        setupCollectionView()
    }
    
    private func setupCollectionView() {
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        collectionView.delegate = self
        collectionView.dataSource = self
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
}

extension LibraryViewController: UICollectionViewDataSource {

    func collectionView(
        _ collectionView: UICollectionView,
        cellForItemAt indexPath: IndexPath
    ) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(
            withReuseIdentifier: LibraryCell.identifier,
            for: indexPath
        ) as! LibraryCell
        cell.backgroundColor = .red
        return cell
    }

    func collectionView(
        _ collectionView: UICollectionView,
        numberOfItemsInSection section: Int
    ) -> Int {
        20
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

extension LibraryViewController: UICollectionViewDelegate {}

final class LibraryCell: UICollectionViewCell {
    
    static let identifier = String(describing: LibraryCell.self)
}
