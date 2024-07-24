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
    private var onPickImages: (([UIImage]) -> Void)?

    func show(on viewController: UIViewController?, onPickImages: @escaping ([UIImage]) -> Void) {
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
        var images: [UIImage] = []

        let group = DispatchGroup()

        for result in results {
            group.enter()

            result.itemProvider.loadObject(ofClass: UIImage.self) { (image, error) in
                if let image = image as? UIImage {
                    images.append(image)
                }
                group.leave()
            }
        }

        group.notify(queue: DispatchQueue.main) {
            self.onPickImages?(images)
            self.viewController?.dismiss(animated: true)
        }
    }
}
