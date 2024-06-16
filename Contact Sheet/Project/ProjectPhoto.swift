//
//  ProjectImage.swift
//  Contact Sheet
//
//  Created by Windy on 14/06/24.
//

import UIKit

struct ProjectPhoto: Hashable {
    let id = UUID()
    let photoURL: URL?
    var assetIdentifier: String? = nil
}

extension Array where Element == ProjectPhoto {

    func addImages(_ images: [String], from startingIndex: Int) -> [Element] {
        var imageIds = images
        var items = self
        items[startingIndex] = ProjectPhoto(photoURL: nil, assetIdentifier: imageIds[0])
        imageIds.remove(at: 0)

        for id in imageIds {
            if let index = items.firstIndex(where: {$0.photoURL == nil && $0.assetIdentifier == nil}) {
                items[index] = ProjectPhoto(photoURL: nil, assetIdentifier: id)
            }
        }
        return items
    }

    func addImage(_ image: URL?, at index: Int) -> [Element] {
        var items = self
        items[index] = ProjectPhoto(photoURL: image)
        return items
    }
    
    func removeImage(at index: Int) -> [Element] {
        var items = self
        items[index] = ProjectPhoto(photoURL: nil)
        return items
    }
    
    func movedItem(at sourceIndex: Int, to destinationIndex: Int) -> [Element] {
        var items = self
        let removedItem = items.remove(at: sourceIndex)
        items.insert(removedItem, at: destinationIndex)
        return items
    }

}
