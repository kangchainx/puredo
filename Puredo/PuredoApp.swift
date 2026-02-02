//
//  PuredoApp.swift
//  Puredo
//
//  Created by Chris Kang on 2026/2/1.
//

import SwiftUI
import SwiftData
import AppKit

@main
struct PuredoApp: App {
    @StateObject private var themeManager = ThemeManager()
    
    init() {
        NSWindow.allowsAutomaticWindowTabbing = false
    }
    
    var body: some Scene {
        WindowGroup {
            MainView()
                .environmentObject(themeManager)
        }
        .windowStyle(.hiddenTitleBar)
        .windowToolbarStyle(.unified)
        .defaultSize(width: 420, height: 840)
        .modelContainer(for: Task.self)
        .commands {
            // Replace new item command to prevent Cmd+N from creating new window
            // but keep other system commands (Edit menu, etc.)
            CommandGroup(replacing: .newItem) {
                // Empty - disables "New Window" but keeps other commands
            }
        }
    }
}
