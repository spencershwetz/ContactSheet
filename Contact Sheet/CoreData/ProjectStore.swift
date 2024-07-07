//
//  ProjectStore.swift
//  Contact Sheet
//
//  Created by Windy on 15/06/24.
//

import CoreData
import UIKit

struct Project: Hashable {
    let id: UUID
    var pageSizeRatio: Ratio
    var photoAspectRatio: Ratio
    var totalRows: Int
    var totalColumns: Int
    var photos: [Photo]
    var title: String

    struct Ratio: Hashable, Codable {
        let width: CGFloat
        let height: CGFloat
    }
    struct Photo: Hashable, Codable {
        enum CodingKeys: CodingKey {
            case assetIdentifier
            case croppedImage
        }

        let assetIdentifier: String?
        let croppedImage: UIImage?

        init(assetIdentifier: String?, croppedImage: UIImage?) {
            self.assetIdentifier = assetIdentifier
            self.croppedImage = croppedImage
        }

        init(from decoder: Decoder) throws {
            let container = try decoder.container(keyedBy: CodingKeys.self)

            assetIdentifier = try? container.decodeIfPresent(String.self, forKey: .assetIdentifier)
            let imageData = try? container.decodeIfPresent(Data.self, forKey: .croppedImage)

            if let imageData {
                self.croppedImage = UIImage(data: imageData)
            } else {
                self.croppedImage = nil
            }
        }

        func encode(to encoder: Encoder) throws {
            var container = encoder.container(keyedBy: CodingKeys.self)
            try container.encode(assetIdentifier, forKey: .assetIdentifier)

            if let jpegData = croppedImage?.pngData() {
                try container.encode(jpegData, forKey: .croppedImage)
            }
        }
    }
}

struct ProjectStore {
    
    private init() {}

    static let shared = ProjectStore()
    
    private var context: NSManagedObjectContext {
        CoreDataContainer.shared.context
    }

    func create(id: UUID) {
        create(Project(
            id: id,
            pageSizeRatio: Project.Ratio(width: 16, height: 9),
            photoAspectRatio: Project.Ratio(width: 1, height: 1),
            totalRows: 4,
            totalColumns: 3,
            photos: (0..<12).map { _ in .init(assetIdentifier: nil, croppedImage: nil) },
            title: "Untitled Project"
        ))
    }

    func get(id: UUID) -> Project? {
        let request = ProjectEntity.fetchRequest()
        request.predicate = NSPredicate(format: "id == %@", id as CVarArg)

        request.fetchLimit = 1
        let result = try? context.fetch(request
        )
        return (result?.compactMap {
            Project(
                id: $0.id!,
                pageSizeRatio: $0.pageSizeRatio!.decode(),
                photoAspectRatio: $0.photoAspectRatio!.decode(),
                totalRows: Int($0.totalRows),
                totalColumns: Int($0.totalColumns),
                photos: $0.photos!.decode(),
                title: $0.title ?? ""
            )
        } ?? []).first

    }

    func create(_ project: Project) {
        let newProject = ProjectEntity(context: context)
        newProject.id = project.id
        newProject.title = project.title
        newProject.pageSizeRatio = project.pageSizeRatio.toData()
        newProject.photoAspectRatio = project.photoAspectRatio.toData()
        newProject.totalRows = Int16(project.totalRows)
        newProject.totalColumns = Int16(project.totalColumns)
        newProject.photos = project.photos.toData()
        context.saveIfNeeded()
    }
    
    func get() -> [Project] {
        let result = try? context.fetch(ProjectEntity.fetchRequest())
        return result?.compactMap {
            Project(
                id: $0.id!,
                pageSizeRatio: $0.pageSizeRatio!.decode(),
                photoAspectRatio: $0.photoAspectRatio!.decode(),
                totalRows: Int($0.totalRows),
                totalColumns: Int($0.totalColumns),
                photos: $0.photos!.decode(),
                title: $0.title ?? ""
            )
        } ?? []
    }

    func update(project: Project) {
        let request = ProjectEntity.fetchRequest()
        request.predicate = NSPredicate(format: "id == %@", project.id as CVarArg)
        request.fetchLimit = 1
        
        guard let projectToBeUpdated = try? context.fetch(request).first else { return }
        projectToBeUpdated.pageSizeRatio = project.pageSizeRatio.toData()
        projectToBeUpdated.photoAspectRatio = project.photoAspectRatio.toData()
        projectToBeUpdated.totalRows = Int16(project.totalRows)
        projectToBeUpdated.totalColumns = Int16(project.totalColumns)
        projectToBeUpdated.photos = project.photos.toData()
        projectToBeUpdated.title = project.title
        
        context.saveIfNeeded()
    }

    func delete(id: UUID) {
        let request = ProjectEntity.fetchRequest()
        request.fetchLimit = 1
        
        guard let projectToBeDeleted = try? context.fetch(request).first else { return }
        context.delete(projectToBeDeleted)
        context.saveIfNeeded()
    }
}

private extension Array where Element == Project.Photo {

    func toData() -> Data? {
        try? JSONEncoder().encode(self)
    }
}

private extension Array where Element == Optional<String> {

    func toData() -> Data? {
        try? JSONEncoder().encode(self)
    }
}

private extension Project.Ratio {
    
    func toData() -> Data? {
        let encoder = JSONEncoder()
        return try? encoder.encode(self)
    }
}

private extension Data {
    
    func decode<T: Decodable>() -> T {
        let decoder = JSONDecoder()
        return try! decoder.decode(T.self, from: self)
    }
}
