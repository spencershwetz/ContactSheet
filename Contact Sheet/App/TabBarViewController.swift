//
//  TabBarViewController.swift
//  Contact Sheet
//
//  Created by Windy on 12/06/24.
//

import UIKit

final class TabBarController: UITabBarController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        viewControllers = [
            makeLibraryViewController(),
            makeCreateViewController(),
            makeExportViewController()
        ]
    }
    
    private func makeLibraryViewController() -> UIViewController {
        let vc = LibraryViewController()
        let navigationController = UINavigationController(rootViewController: vc)
        navigationController.navigationBar.prefersLargeTitles = true
        vc.tabBarItem = UITabBarItem(
            title: "Library",
            image: UIImage(systemName: "folder.fill"),
            tag: 0
        )
        vc.title = "Library"
        return navigationController
    }
    
    private func makeCreateViewController() -> UIViewController {
        let vc = ProjectViewController()
        let navigationController = UINavigationController(rootViewController: vc)
        vc.tabBarItem = UITabBarItem(
            title: "Create",
            image: UIImage(systemName: "folder.fill.badge.plus"),
            tag: 1
        )
        return navigationController
    }
    
    private func makeExportViewController() -> UIViewController {
        let vc = ExportViewController()
        let navigationController = UINavigationController(rootViewController: vc)
        navigationController.navigationBar.prefersLargeTitles = true
        vc.tabBarItem = UITabBarItem(
            title: "Export",
            image: UIImage(systemName: "square.and.arrow.up.fill"),
            tag: 2
        )
        vc.title = "Export"
        return navigationController
    }
}
