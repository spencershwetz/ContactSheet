//
//  CoreDataContainer.swift
//  Contact Sheet
//
//  Created by Windy on 15/06/24.
//

import CoreData

final class CoreDataContainer {
    
    var context: NSManagedObjectContext {
        let viewContext = container.viewContext
        viewContext.mergePolicy = NSMergeByPropertyObjectTrumpMergePolicy
        viewContext.automaticallyMergesChangesFromParent = true
        return viewContext
    }
    
    static let shared = CoreDataContainer()
    
    private init() {}
    
    private lazy var persistentContainer: NSPersistentContainer = {
        let container = NSPersistentContainer(name: "ContactSheet")
        container.loadPersistentStores(completionHandler: { (storeDescription, error) in
            if let error = error as NSError? {
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        })
        return container
    }()

    private lazy var persistentCloudContainer: NSPersistentCloudKitContainer = {
        let container = NSPersistentCloudKitContainer(name: "ContactSheet")
        let description = container.persistentStoreDescriptions.first!
        description.setOption(
            true as NSNumber,
            forKey: NSPersistentHistoryTrackingKey
        )
        description.setOption(
            true as NSNumber,
            forKey: NSPersistentStoreRemoteChangeNotificationPostOptionKey
        )
        description.cloudKitContainerOptions = NSPersistentCloudKitContainerOptions(
            containerIdentifier: "iCloud.com.spencershwetz.ContactSheet"
        )
        container.loadPersistentStores(completionHandler: { (storeDescription, error) in
            if let error = error as NSError? {
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        })
        return container
    }()
    
    private var container: NSPersistentContainer {
        if AppUserDefaults.bool(forKey: .enabledICloudSync) {
            return persistentCloudContainer
        } else {
            return persistentContainer
        }
    }
}

