//
//  ImagePicker.swift
//  Contact Sheet
//
//  Created by Windy on 13/06/24.
//

import UIKit

final class ImagePicker: NSObject {
    
    private weak var viewController: UIViewController?
    private var onPickImage: ((URL) -> Void)?

    func show(on viewController: UIViewController?, onPickImage: @escaping (URL) -> Void) {
        let imagePickerController = UIImagePickerController()
        imagePickerController.sourceType = .photoLibrary
        imagePickerController.delegate = self
        self.onPickImage = onPickImage
        self.viewController = viewController
        viewController?.present(imagePickerController, animated: true)
    }
    
}

extension ImagePicker: UIImagePickerControllerDelegate, UINavigationControllerDelegate {

    func imagePickerController(
        _ picker: UIImagePickerController,
        didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any]
    ) {
        guard let image = info[.imageURL] as? URL else { return }
        onPickImage?(image)
        viewController?.dismiss(animated: true)
    }
}
