//
//  ImagePicker.swift
//  Contact Sheet
//
//  Created by Windy on 13/06/24.
//

import UIKit

final class ImagePicker: NSObject {
    
    private weak var viewController: UIViewController?
    private var onPickImage: ((UIImage) -> Void)?

    func show(on viewController: UIViewController?, onPickImage: @escaping (UIImage) -> Void) {
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
        guard let image = info[.originalImage] as? UIImage else { return }
        onPickImage?(image)
        viewController?.dismiss(animated: true)
    }
}
