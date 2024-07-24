//
//  ImageEntityStore.swift
//  Contact Sheet
//
//  Created by Jaymeen Unadkat on 21/07/24.
//

import CoreData
import UIKit

/**
 //MARK: - ImageEntityStore
class ImageEntityStore {
    private init() {}

    static let shared = ImageEntityStore()

    private var context: NSManagedObjectContext {
        CoreDataContainer.shared.context
    }


    // MARK: - Create
    func createImageEntity(url: URL, for projectEntity: ProjectEntity) -> ImageEntity {
        let imageEntity = ImageEntity(context: context)
        imageEntity.url = url.absoluteString
        imageEntity.projectEntity = projectEntity
        projectEntity.addToImages(imageEntity)
        context.saveIfNeeded()
        return imageEntity
    }

    func createImageEntities(urls: [URL], for projectEntity: ProjectEntity) {
        for url in urls {
            let imageEntity = ImageEntity(context: context)
            imageEntity.url = url.absoluteString
            imageEntity.projectEntity = projectEntity
            projectEntity.addToImages(imageEntity)
        }
        context.saveIfNeeded()
    }


    // MARK: - Read
    func fetchImageEntities(for projectEntity: ProjectEntity) -> [ImageEntity] {
        let fetchRequest: NSFetchRequest<ImageEntity> = ImageEntity.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "projectEntity == %@", projectEntity)

        do {
            let results = try context.fetch(fetchRequest)
            return results
        } catch {
            print("Failed to fetch ImageEntities: \(error)")
            return []
        }
    }

    func fetchImageEntity(with url: URL) -> ImageEntity? {
        let fetchRequest: NSFetchRequest<ImageEntity> = ImageEntity.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "url == %@", url.absoluteString)

        do {
            let results = try context.fetch(fetchRequest)
            return results.first
        } catch {
            print("Failed to fetch ImageEntity: \(error)")
            return nil
        }
    }

    // MARK: - Update
    func updateImageEntity(_ imageEntity: ImageEntity, newURL: URL?) {
        if let newURL = newURL {
            imageEntity.url = newURL.absoluteString
        }
        context.saveIfNeeded()
    }

    // MARK: - Delete
    func deleteImageEntity(_ imageEntity: ImageEntity) {
        context.delete(imageEntity)
        context.saveIfNeeded()
    }

    func saveImageURL(url: URL, to projectEntity: ProjectEntity) {
        let imageEntity = ImageEntity(context: context)
        imageEntity.url = url.absoluteString
        imageEntity.projectEntity = projectEntity
        projectEntity.addToImages(imageEntity)
        context.saveIfNeeded()
    }

    func fetchProjectEntitiesWithImages() -> [ProjectEntity] {
        let fetchRequest: NSFetchRequest<ProjectEntity> = ProjectEntity.fetchRequest()

        do {
            let results = try context.fetch(fetchRequest)
            return results
        } catch {
            print("Failed to fetch ProjectEntities: \(error)")
            return []
        }
    }
}
*/
