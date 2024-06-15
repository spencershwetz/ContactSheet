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
}

extension Array where Element == ProjectPhoto {
    
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
