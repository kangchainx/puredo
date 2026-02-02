//
//  MainView.swift
//  Puredo
//
//  Created by Chris Kang on 2026/2/1.
//

import SwiftUI
import SwiftData
import AppKit

struct MainView: View {
    @Environment(\.modelContext) private var modelContext
    @EnvironmentObject private var themeManager: ThemeManager
    @State private var viewModel: TaskViewModel?
    
    private let defaultWindowSize = NSSize(width: 420, height: 840)
    private let minimumWindowSize = NSSize(width: 320, height: 500)

    var body: some View {
        Group {
            if let viewModel = viewModel {
                VStack(spacing: 0) {
                    HeaderView(viewModel: viewModel)
                    
                    TaskListView(viewModel: viewModel)
                }
                .background(themeManager.background)
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .transition(.opacity.combined(with: .scale(scale: 0.95)))
            }
        }
        .frame(
            minWidth: minimumWindowSize.width,
            minHeight: minimumWindowSize.height
        )
        .onAppear {
            if viewModel == nil {
                viewModel = TaskViewModel(modelContext: modelContext)
            }
            
            DispatchQueue.main.async {
                configureWindow()
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                configureWindow()
            }
        }
    }
    
    private func configureWindow() {
        if let window = activeWindow() {
            window.tabbingMode = .disallowed
            window.minSize = minimumWindowSize
            
            let visibleFrame = window.screen?.visibleFrame ?? NSScreen.main?.visibleFrame ?? .zero
            let maxWidth = max(minimumWindowSize.width, visibleFrame.width - 80)
            let maxHeight = max(minimumWindowSize.height, visibleFrame.height - 80)
            
            var targetWidth = min(defaultWindowSize.width, maxWidth)
            var targetHeight = targetWidth * 2
            
            if targetHeight > maxHeight {
                targetHeight = maxHeight
                targetWidth = targetHeight / 2
            }

            let targetFrame = NSRect(
                x: window.frame.origin.x,
                y: window.frame.origin.y + window.frame.height - targetHeight,
                width: targetWidth,
                height: targetHeight
            )
            
            guard targetFrame.size != window.frame.size else { return }
            window.setFrame(targetFrame, display: true, animate: true)
        }
    }
    
    private func activeWindow() -> NSWindow? {
        NSApplication.shared.keyWindow
            ?? NSApplication.shared.mainWindow
            ?? NSApplication.shared.windows.first(where: { $0.isVisible && $0.canBecomeMain })
            ?? NSApplication.shared.windows.first
    }
}

#Preview {
    MainView()
        .modelContainer(for: Task.self, inMemory: true)
        .environmentObject(ThemeManager())
}
