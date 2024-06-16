//
//  ImagePicker.swift
//  Contact Sheet
//
//  Created by Windy on 13/06/24.
//

import UIKit
import PhotosUI

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

final class MultiImagePicker: NSObject {

    private weak var viewController: UIViewController?
    private var onPickImages: (([String]) -> Void)?

    func show(on viewController: UIViewController?, maxLimit: Int? = nil, onPickImages: @escaping ([String]) -> Void) {
        let photoLibrary = PHPhotoLibrary.shared()
        var configuration = PHPickerConfiguration(photoLibrary: photoLibrary)
        configuration.selectionLimit = 0
        configuration.filter = .images
        /// configuration.filter = .any([.videos,livePhotos])
        let picker = PHPickerViewController(configuration: configuration)
        self.onPickImages = onPickImages
        self.viewController = viewController
        picker.delegate = self
        viewController?.present(picker, animated: true)
    }
    
}

extension MultiImagePicker: PHPickerViewControllerDelegate {
    func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {
        var pickedImageIds: [String] = []

        for result in results {
            if let identifier = result.assetIdentifier {
                pickedImageIds.append(identifier)
            }
        }

        DispatchQueue.main.async { [weak self] in
            self?.onPickImages?(pickedImageIds)
            self?.viewController?.dismiss(animated: true)
        }
    }
}
