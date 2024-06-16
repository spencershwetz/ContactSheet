//
//  ProjectStore.swift
//  Contact Sheet
//
//  Created by Windy on 15/06/24.
//

import CoreData

struct Project: Hashable {
    let id: UUID
    let pageSizeRatio: Ratio
    let photoAspectRatio: Ratio
    let totalRows: Int
    let totalColumns: Int
    let photos: [String?]
    let title: String

    struct Ratio: Hashable, Codable {
        let width: CGFloat
        let height: CGFloat
    }
}

struct ProjectStore {
    
    private init() {}

    static let shared = ProjectStore()
    
    private var context: NSManagedObjectContext {
        CoreDataContainer.shared.context
    }
    
    func create(id: UUID) {
        let project = ProjectEntity(context: context)
        project.id = id
        project.title = "Untitled Project"
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

private extension Array where Element == Optional<URL> {
    
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
