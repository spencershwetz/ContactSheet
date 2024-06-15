//
//  NSManageObjectContext+Ext.swift
//  Contact Sheet
//
//  Created by Windy on 15/06/24.
//

import CoreData

extension NSManagedObjectContext {
    
    func saveIfNeeded() {
        if hasChanges {
            do {
                try save()
            } catch {
                print("@@@Failed to save", error)
            }
        }
    }
}
