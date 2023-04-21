//
//  iAppTrimApp.swift
//  iAppTrim
//
//  Created by Jerrydu on 2023/4/21.
//

import SwiftUI

@main
struct iAppTrimApp: App {
    let persistenceController = PersistenceController.shared

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
                .frame(minWidth: 1000, minHeight: 500)
        }
    }
}
