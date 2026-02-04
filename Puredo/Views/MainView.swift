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
    @State private var hasConfiguredWindow = false
    @State private var showMinimalModeNotification = false
    
    private let defaultWindowSize = NSSize(width: 420, height: 840)
    private let minimumWindowSize = NSSize(width: 320, height: 500)
    private let minimalModeMinimumSize = NSSize(width: 240, height: 300)

    var body: some View {
        ZStack {
            Group {
                if let viewModel = viewModel {
                    if themeManager.isMinimalMode {
                        // Minimal mode: Only task list, compact layout
                        MinimalTaskListView(viewModel: viewModel)
                    } else {
                        // Standard mode: Header + Task list + Status bar
                        VStack(spacing: 0) {
                            HeaderView(viewModel: viewModel, showMinimalModeNotification: $showMinimalModeNotification)
                            
                            TaskListView(viewModel: viewModel)
                            
                            StatusBarView(viewModel: viewModel)
                        }
                    }
                }
            }
            .background(themeManager.background)
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .transition(.opacity.combined(with: .scale(scale: 0.95)))
            
            // Notification overlay
            if showMinimalModeNotification {
                VStack {
                    Spacer()
                    
                    HStack {
                        Spacer()
                        
                        MinimalModeNotification(
                            isPresented: $showMinimalModeNotification,
                            onConfirm: {
                                themeManager.toggleMinimalMode()
                            },
                            onCancel: {
                                // Do nothing, just dismiss
                            }
                        )
                        .padding(DesignSystem.spacingL)
                    }
                }
                .transition(.asymmetric(
                    insertion: .move(edge: .trailing).combined(with: .opacity),
                    removal: .move(edge: .trailing).combined(with: .opacity)
                ))
            }
        }
        .frame(
            minWidth: themeManager.isMinimalMode ? minimalModeMinimumSize.width : minimumWindowSize.width,
            minHeight: themeManager.isMinimalMode ? minimalModeMinimumSize.height : minimumWindowSize.height
        )
        .onAppear {
            if viewModel == nil {
                viewModel = TaskViewModel(modelContext: modelContext)
            }
            
            // Only configure window on first launch, not on every appear
            if !hasConfiguredWindow {
                DispatchQueue.main.async {
                    configureWindow()
                    hasConfiguredWindow = true
                }
            } else {
                // Just set constraints without resizing
                DispatchQueue.main.async {
                    setWindowConstraints()
                }
            }
        }
        .onChange(of: themeManager.isMinimalMode) { oldValue, newValue in
            // Update window constraints when switching modes
            updateWindowConstraintsForMode()
        }
    }
    
    private func updateWindowConstraintsForMode() {
        if let window = activeWindow() {
            if themeManager.isMinimalMode {
                window.minSize = minimalModeMinimumSize
            } else {
                window.minSize = minimumWindowSize
            }
        }
    }
    
    private func setWindowConstraints() {
        if let window = activeWindow() {
            window.tabbingMode = .disallowed
            window.minSize = minimumWindowSize
        }
    }
    
    private func configureWindow() {
        if let window = activeWindow() {
            window.tabbingMode = .disallowed
            window.minSize = minimumWindowSize
            
            // Only set size if window hasn't been resized by user
            let currentSize = window.frame.size
            let isDefaultSize = abs(currentSize.width - 800) < 10 && abs(currentSize.height - 600) < 10
            
            if isDefaultSize {
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
                
                window.setFrame(targetFrame, display: true, animate: false)
            }
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
