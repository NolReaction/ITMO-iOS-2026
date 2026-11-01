//
//  ITMO_projApp.swift
//  ITMO-proj
//
//  Created by Дмитрий Сломов on 10.09.2026.
//

import SwiftUI
import SwiftData

@main
struct ITMO_projApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
        .modelContainer(for: Lab4Note.self, inMemory: WatchNextUITestSupport.isEnabled)
    }
}

