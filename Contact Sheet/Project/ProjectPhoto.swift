//
//  ProjectImage.swift
//  Contact Sheet
//
//  Created by Windy on 14/06/24.
//

import UIKit

/**
struct ProjectPhoto: Hashable {
    let assetIdentifier: String?
    let croppedImage: UIImage?
}


 extension Array where Element == ProjectPhoto {

 func addImages(_ imageIDs: [String], from startingIndex: Int, totalColumns: Int) -> ([Element], addedRows: Int) {
 guard !imageIDs.isEmpty else { return (self, 0) }
 var items = self
 var addedRows: Int = 0

 var imageIDs = imageIDs
 items[startingIndex] = ProjectPhoto(
 assetIdentifier: imageIDs.removeFirst(),
 croppedImage: nil
 )

 for id in imageIDs {
 if let index = items.firstIndex(where: { $0.assetIdentifier == nil}) {
 items[index] = ProjectPhoto(assetIdentifier: id, croppedImage: nil)
 } else {
 addedRows += 1
 for _ in 0..<totalColumns {
 items.append(ProjectPhoto(assetIdentifier: nil, croppedImage: nil))
 }
 if let index = items.firstIndex(where: { $0.assetIdentifier == nil}) {
 items[index] = ProjectPhoto(assetIdentifier: id, croppedImage: nil)
 }

 }
 }
 return (items, addedRows)
 }

 func updatedCroppedImage(_ image: UIImage, at index: Int) -> [Element] {
 let item = self[index]
 var items = self
 items[index] = ProjectPhoto(
 assetIdentifier: item.assetIdentifier,
 croppedImage: image
 )
 return items
 }


 func removeImage(at index: Int) -> [Element] {
 var items = self
 items[index] = ProjectPhoto(assetIdentifier: nil, croppedImage: nil)
 return items
 }

 func movedItem(at sourceIndex: Int, to destinationIndex: Int) -> [Element] {
 var items = self
 let removedItem = items.remove(at: sourceIndex)
 items.insert(removedItem, at: destinationIndex)
 return items
 }

 }

 */

/**struct CloudPhoto: Hashable {
    let imageURL: String?
    let editImageURL: String?
}*/

struct CloudPhoto: Hashable {
    let id: UUID
    let imageURL: String?
    let editImageURL: String?

    init(id: UUID = UUID(), imageURL: String?, editImageURL: String?) {
        self.id = id
        self.imageURL = imageURL
        self.editImageURL = editImageURL
    }

    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }

    static func == (lhs: CloudPhoto, rhs: CloudPhoto) -> Bool {
        return lhs.id == rhs.id
    }
}


extension Array where Element == CloudPhoto {

    func addImages(_ imageURLs: [String], from startingIndex: Int, totalColumns: Int) -> ([Element], addedRows: Int) {
        guard !imageURLs.isEmpty else { return (self, 0) }
        var items = self
        var addedRows: Int = 0

        var imageURLs = imageURLs
        items[startingIndex] = CloudPhoto(
            imageURL: imageURLs.removeFirst(),
            editImageURL: nil
        )

        for url in imageURLs {
            if let index = items.firstIndex(where: { $0.imageURL == nil}) {
                items[index] = CloudPhoto(imageURL: url, editImageURL: nil)
            } else {
                addedRows += 1
                for _ in 0..<totalColumns {
                    items.append(CloudPhoto(imageURL: nil, editImageURL: nil))
                }
                if let index = items.firstIndex(where: { $0.imageURL == nil}) {
                    items[index] = CloudPhoto(imageURL: url, editImageURL: nil)
                }

            }
        }
        return (items, addedRows)
    }

    func updatedCroppedImage(_ editImageURL: String, at index: Int) -> [Element] {
        let item = self[index]
        var items = self
        items[index] = CloudPhoto(
            imageURL: item.imageURL,
            editImageURL: editImageURL
        )
        return items
    }


    func removeImage(at index: Int) -> [Element] {
        var items = self
        items[index] = CloudPhoto(
            imageURL: nil,
            editImageURL: nil
        )
        return items
    }

    func movedItem(at sourceIndex: Int, to destinationIndex: Int) -> [Element] {
        var items = self
        let removedItem = items.remove(at: sourceIndex)
        items.insert(removedItem, at: destinationIndex)
        return items
    }

}
