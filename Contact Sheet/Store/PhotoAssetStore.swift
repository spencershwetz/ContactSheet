//
//  PhotoAssetStore.swift
//  Contact Sheet
//
//  Created by Jaymeen Unadkat on 16/06/24.
//

import Foundation
import Photos
import UIKit

final class PhotoAssetStore {

    private var cachesImages: [String: UIImage] = [:]
    
    static let shared = PhotoAssetStore()
    
    private init() {}

    func getImagesWithLocalIds(identifiers: [String], completion: @escaping ((_ images: [UIImage]) -> ()?)) {
        var images: [UIImage] = []
        let options = PHFetchOptions()
        let results = PHAsset.fetchAssets(withLocalIdentifiers: identifiers, options: options)
        let manager = PHImageManager.default()
        let dispatchGroup = DispatchGroup()

        results.enumerateObjects { (thisAsset, _, _) in
            dispatchGroup.enter()
            manager.requestImage(for: thisAsset, targetSize: CGSize(width: 200.0, height: 200.0), contentMode: .aspectFit, options: nil, resultHandler: {(image, _) in
                if let image {
                    images.append(image)
                }
                dispatchGroup.leave()
            })
        }
        dispatchGroup.notify(queue: .main) {
            completion(images)
        }
    }

    func getImageWithLocalId(identifier: String, completion: @escaping (UIImage?) -> Void) {
        if let image = cachesImages[identifier] {
            completion(image)
        } else {
            let results = PHAsset.fetchAssets(withLocalIdentifiers: [identifier], options: nil)
            let manager = PHImageManager.default()
            let imageRequestOption = PHImageRequestOptions()
            imageRequestOption.deliveryMode = .highQualityFormat

            results.enumerateObjects { asset, _, _ in
                manager.requestImage(
                    for: asset,
                    targetSize: CGSize(width: 1024.0, height: 1024.0),
                    contentMode: .aspectFit,
                    options: imageRequestOption,
                    resultHandler: { [weak self] image, _ in
                        self?.cachesImages[identifier] = image
                        completion(image)
                    }
                )
            }
        }
    }
}
