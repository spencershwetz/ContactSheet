//
//  ExportViewController.swift
//  Contact Sheet
//
//  Created by Windy on 12/06/24.
//

import UIKit
import SwiftUI

///`ExportViewController`
final class ExportViewController: UIViewController {
    
    private let bgLabel = UILabel()
    private let selectImageView = UIImageView()
    private var shareButtonBarItem: UIBarButtonItem!
    private var vm: ExportViewModel = ExportViewModel()
    private let store = ProjectStore.shared
    private var project: Project

    init(project: Project) {
        self.project = project
        self.vm.selectedProject = project
        self.vm.fetchAllImages()
        UIScrollView.appearance().bounces = false
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        UIView.setAnimationsEnabled(true)
        store.update(project: vm.selectedProject)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = self.project.title
        view.backgroundColor = .systemBackground
        navigationItem.largeTitleDisplayMode = .never
        addExportView()
        setUpNavBar()
    }
}

extension ExportViewController {
    
    func setUpNavBar() {
        let tapGestureRecognizer = UITapGestureRecognizer(
            target: self,
            action: #selector(handleRenameAction)
        )
        navigationController?.navigationBar.addGestureRecognizer(tapGestureRecognizer)

        shareButtonBarItem = UIBarButtonItem(
            image: UIImage(systemName: "square.and.arrow.up"),
            style: .plain,
            target: self,
            action: #selector(handleShareProject)
        )
        navigationItem.rightBarButtonItems = [
            shareButtonBarItem
        ]
    }

    @objc private func handleRenameAction() {
        let alert = UIAlertController(
            title: "Project Name",
            message: "Please enter project name",
            preferredStyle: .alert
        )

        alert.addTextField { [weak self] textField in
            textField.placeholder = "Name"
            textField.keyboardType = .default
            textField.text = self?.project.title
        }

        let submitAction = UIAlertAction(
            title: "Done",
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
            self.project = project
            store.update(project: project)
            vm.selectedProject = project
            title = nameText
        }

        alert.addAction(submitAction)
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        present(alert, animated: true)
    }
}

extension ExportViewController {
    @objc
    private func handleShareProject() {
        NotificationCenter.default.post(Notification(name: .renderImage))
    }
}
#Preview(body: {
    return makeExportViewController().asPreview()

    func makeExportViewController() -> UIViewController {
        let vc = ExportViewController(project: Project(id: UUID(), pageSizeRatio: .init(width: 0, height: 0), photoAspectRatio: .init(width: 0, height: 0), totalRows: 0, totalColumns: 0, photos: [], title: ""))
        let navigationController = UINavigationController(rootViewController: vc)
        navigationController.navigationBar.prefersLargeTitles = true
        vc.title = "Export"
        return navigationController
    }
})


extension ExportViewController {
    /// Adding the Export SwiftUI view as a hosting controller
    func addExportView() {
        let controller = UIHostingController(rootView: ExportView(exportVM: self.vm))
        addChild(controller)
        controller.view.translatesAutoresizingMaskIntoConstraints = false
        controller.didMove(toParent: self)
        view.addSubview(controller.view, constraint: .fill)
    }
}
