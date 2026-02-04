//
//  HeaderView.swift
//  Puredo
//
//  Created by Chris Kang on 2026/2/1.
//

import SwiftUI
import SwiftData
import AppKit

struct HeaderView: View {
    @Bindable var viewModel: TaskViewModel
    @EnvironmentObject private var themeManager: ThemeManager
    @Binding var showMinimalModeNotification: Bool
    @State private var showingAddTask = false
    @State private var showingSettings = false
    @State private var isPinned = false
    
    var body: some View {
        VStack(spacing: DesignSystem.spacingM) {
            HStack(alignment: .top) {
                // Left side: Title only
                Text("待办清单")
                    .font(.system(size: 22, weight: .bold))
                    .foregroundColor(themeManager.textPrimary)

                Spacer()

                // Right side: Theme toggle, Pin button and Add button
                HStack(spacing: DesignSystem.spacingM) {
                    // Secondary buttons group (more subtle)
                    HStack(spacing: DesignSystem.spacingXS) {
                        // Settings menu button
                        Button(action: { showingSettings = true }) {
                            Image(systemName: "gear")
                                .font(.system(size: 16))
                                .foregroundColor(themeManager.textTertiary)
                                .frame(width: 28, height: 28)
                        }
                        .buttonStyle(.plain)
                        .help("设置")
                        .popover(isPresented: $showingSettings, arrowEdge: .bottom) {
                            SettingsMenuView()
                        }
                        .opacity(0.7)
                        
                        // Theme toggle button
                        Button(action: { themeManager.toggle() }) {
                            Image(systemName: themeManager.currentTheme == .dark ? "moon.fill" : "sun.max.fill")
                                .font(.system(size: 16))
                                .foregroundColor(themeManager.textTertiary)
                                .frame(width: 28, height: 28)
                        }
                        .buttonStyle(.plain)
                        .help(themeManager.currentTheme == .dark ? "深色模式" : "浅色模式")
                        .opacity(0.7)
                        
                        // Pin button
                        Button(action: { togglePin() }) {
                            Image(systemName: isPinned ? "pin.fill" : "pin")
                                .font(.system(size: 16))
                                .foregroundColor(isPinned ? themeManager.accent : themeManager.textTertiary)
                                .frame(width: 28, height: 28)
                        }
                        .buttonStyle(.plain)
                        .help(isPinned ? "取消置顶" : "窗口置顶")
                        .opacity(isPinned ? 1.0 : 0.7)
                    }
                    
                    // Primary action button (prominent)
                    Button(action: { showingAddTask = true }) {
                        Image(systemName: "plus.circle.fill")
                            .font(.system(size: 32))
                            .foregroundColor(themeManager.accent)
                    }
                    .buttonStyle(.plain)
                    .keyboardShortcut("n", modifiers: .command)
                    .popover(isPresented: $showingAddTask) {
                        AddTaskPopoverView(viewModel: viewModel, isPresented: $showingAddTask)
                    }
                    .shadow(color: themeManager.accent.opacity(0.25), radius: 4, x: 0, y: 2)
                }
            }

            HStack {
                Image(systemName: "magnifyingglass")
                    .foregroundColor(themeManager.textSecondary)

                ZStack(alignment: .leading) {
                    if viewModel.searchText.isEmpty {
                        Text("搜索任务")
                            .foregroundColor(themeManager.textSecondary)
                            .allowsHitTesting(false)
                    }
                    
                    TextField("", text: $viewModel.searchText)
                        .textFieldStyle(.plain)
                        .foregroundColor(themeManager.textPrimary)
                }
            }
            .padding(DesignSystem.spacingM)
            .background(themeManager.surface)
            .cornerRadius(DesignSystem.cornerRadiusM)
            .overlay(
                RoundedRectangle(cornerRadius: DesignSystem.cornerRadiusM)
                    .stroke(themeManager.border, lineWidth: 1)
            )
        }
        .padding(DesignSystem.spacingL)
        .background(themeManager.backgroundSecondary)
        .onAppear {
            // Sync pin state with actual window level
            updatePinState()
        }
        .onChange(of: themeManager.isMinimalMode) { oldValue, newValue in
            // When exiting minimal mode, check and restore pin state
            if !newValue {
                updatePinState()
            }
        }
    }

    private func updatePinState() {
        if let window = NSApplication.shared.windows.first {
            isPinned = window.level == .floating
        }
    }
    
    private func togglePin() {
        if !isPinned {
            // Pin the window
            isPinned = true
            
            if let window = NSApplication.shared.windows.first {
                window.level = .floating
            }
            
            // Check if auto minimal mode is enabled
            if themeManager.autoMinimalModeOnPin {
                // Directly switch to minimal mode
                themeManager.toggleMinimalMode()
            } else {
                // Show notification to ask user
                showMinimalModeNotification = true
            }
        } else {
            // Unpin the window
            isPinned = false
            
            if let window = NSApplication.shared.windows.first {
                window.level = .normal
            }
            
            // If in minimal mode, exit it
            if themeManager.isMinimalMode {
                themeManager.toggleMinimalMode()
            }
        }
    }
}

#Preview {
    let config = ModelConfiguration(isStoredInMemoryOnly: true)
    let container = try! ModelContainer(for: Task.self, configurations: config)
    let viewModel = TaskViewModel(modelContext: container.mainContext)
    
    return HeaderView(viewModel: viewModel, showMinimalModeNotification: .constant(false))
        .frame(width: 800)
        .background(Color.pureBlack)
        .environmentObject(ThemeManager())
}
