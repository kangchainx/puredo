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
    @State private var showingAddTask = false
    @State private var isPinned = false

    var body: some View {
        VStack(spacing: DesignSystem.spacingM) {
            HStack(alignment: .top) {
                // Left side: Title only
                Text("待办清单")
                    .font(.system(size: 28, weight: .bold))
                    .foregroundColor(themeManager.textPrimary)

                Spacer()

                // Right side: Theme toggle, Pin button, Add button and task count
                VStack(alignment: .trailing, spacing: DesignSystem.spacingXS) {
                    HStack(spacing: DesignSystem.spacingS) {
                        // Theme toggle button
                        Button(action: { themeManager.toggle() }) {
                            Image(systemName: themeManager.currentTheme == .dark ? "moon.fill" : "sun.max.fill")
                                .font(.system(size: 18))
                                .foregroundColor(themeManager.textSecondary)
                        }
                        .buttonStyle(.plain)
                        .help(themeManager.currentTheme == .dark ? "深色模式" : "浅色模式")
                        
                        // Pin button
                        Button(action: { togglePin() }) {
                            Image(systemName: isPinned ? "pin.fill" : "pin")
                                .font(.system(size: 18))
                                .foregroundColor(isPinned ? themeManager.accent : themeManager.textSecondary)
                        }
                        .buttonStyle(.plain)
                        .help(isPinned ? "取消置顶" : "窗口置顶")
                        
                        // Add task button
                        Button(action: { showingAddTask = true }) {
                            Image(systemName: "plus.circle.fill")
                                .font(.system(size: 24))
                                .foregroundColor(themeManager.accent)
                        }
                        .buttonStyle(.plain)
                        .keyboardShortcut("n", modifiers: .command)
                        .popover(isPresented: $showingAddTask) {
                            AddTaskPopoverView(viewModel: viewModel, isPresented: $showingAddTask)
                        }
                    }
                    
                    Text(subtitle)
                        .font(.system(size: 14))
                        .foregroundColor(themeManager.textSecondary)
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
    }

    private var subtitle: String {
        let count = viewModel.filteredTasks.filter { !$0.isCompleted }.count
        return "\(count) 个任务"
    }
    
    private func togglePin() {
        if !isPinned {
            // Pin the window
            isPinned = true
            
            if let window = NSApplication.shared.windows.first {
                window.level = .floating
            }
        } else {
            // Unpin the window
            isPinned = false
            
            if let window = NSApplication.shared.windows.first {
                window.level = .normal
            }
        }
    }
}

#Preview {
    let config = ModelConfiguration(isStoredInMemoryOnly: true)
    let container = try! ModelContainer(for: Task.self, configurations: config)
    let viewModel = TaskViewModel(modelContext: container.mainContext)
    
    return HeaderView(viewModel: viewModel)
        .frame(width: 800)
        .background(Color.pureBlack)
        .environmentObject(ThemeManager())
}
