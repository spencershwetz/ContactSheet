//
//  ProjectImage.swift
//  Contact Sheet
//
//  Created by Windy on 14/06/24.
//

import UIKit

struct ProjectPhoto: Hashable {
    let id = UUID()
    let assetIdentifier: String?
}

extension Array where Element == ProjectPhoto {

    func addImages(_ imageIDs: [String], from startingIndex: Int) -> [Element] {
        var imageIDs = imageIDs
        var items = self
        items[startingIndex] = ProjectPhoto(assetIdentifier: imageIDs[0])
        imageIDs.remove(at: 0)

        for id in imageIDs {
            if let index = items.firstIndex(where: { $0.assetIdentifier == nil}) {
                items[index] = ProjectPhoto(assetIdentifier: id)
            }
        }
        return items
    }
    
    func removeImage(at index: Int) -> [Element] {
        var items = self
        items[index] = ProjectPhoto(assetIdentifier: nil)
        return items
    }
    
    func movedItem(at sourceIndex: Int, to destinationIndex: Int) -> [Element] {
        var items = self
        let removedItem = items.remove(at: sourceIndex)
        items.insert(removedItem, at: destinationIndex)
        return items
    }

}
