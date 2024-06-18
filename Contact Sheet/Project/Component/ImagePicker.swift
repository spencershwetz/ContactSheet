//
//  ImagePicker.swift
//  Contact Sheet
//
//  Created by Windy on 13/06/24.
//

import UIKit
import PhotosUI

final class MultiImagePicker: NSObject {

    private weak var viewController: UIViewController?
    private var onPickImages: (([String]) -> Void)?

    func show(on viewController: UIViewController?, onPickImages: @escaping ([String]) -> Void) {
        let photoLibrary = PHPhotoLibrary.shared()
        var configuration = PHPickerConfiguration(photoLibrary: photoLibrary)
        configuration.selectionLimit = 0
        configuration.filter = .images

        let picker = PHPickerViewController(configuration: configuration)
        self.onPickImages = onPickImages
        self.viewController = viewController
        picker.delegate = self
        viewController?.present(picker, animated: true)
    }
    
}

extension MultiImagePicker: PHPickerViewControllerDelegate {
    func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {
        let pickedImageIds = results.compactMap(\.assetIdentifier)
        onPickImages?(pickedImageIds)
        viewController?.dismiss(animated: true)
    }
}
