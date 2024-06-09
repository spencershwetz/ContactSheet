//
//  Contact_SheetApp.swift
//  Contact Sheet
//
//  Created by spencer on 6/8/24.
//

import SwiftUI

@main
struct Contact_SheetApp: App {
    let persistenceController = PersistenceController.shared

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
        }
    }
}
