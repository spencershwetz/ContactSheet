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
    private let project: Project
    var bgColorLabel: String? {
        didSet {
            bgLabel.text = bgColorLabel
        }
    }

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
        store.update(project: vm.selectedProject)
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Export"
        view.backgroundColor = .systemBackground
        navigationItem.largeTitleDisplayMode = .never
        addExportView()
        setUpNavBar()
        view.backgroundColor = .systemBackground
    }
}

extension ExportViewController {
    func setUpNavBar() {
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
        view.addSubview(controller.view)
        controller.didMove(toParent: self)

        NSLayoutConstraint.activate([
            controller.view.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: 1),
            controller.view.heightAnchor.constraint(equalTo: view.heightAnchor, multiplier: 1),
            controller.view.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            controller.view.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        ])
    }
}


