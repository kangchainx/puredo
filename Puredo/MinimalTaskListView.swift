//
//  MinimalTaskListView.swift
//  Puredo
//
//  Created by Chris Kang on 2026/2/3.
//

import SwiftUI
import SwiftData

struct MinimalTaskListView: View {
    @Bindable var viewModel: TaskViewModel
    @EnvironmentObject private var themeManager: ThemeManager
    @State private var showExitHint = true

    var body: some View {
        ZStack {
            ScrollView {
                if viewModel.filteredTasks.isEmpty {
                    emptyStateView
                } else {
                    LazyVStack(spacing: 0) {
                        ForEach(viewModel.filteredTasks) { task in
                            MinimalTaskRowView(task: task) {
                                withAnimation(DesignSystem.springAnimation) {
                                    viewModel.toggleComplete(task)
                                }
                            }
                        }
                    }
                    .padding(.vertical, DesignSystem.spacingS)
                }
            }
            .onTapGesture(count: 2) {
                // Double-click anywhere to exit minimal mode
                themeManager.toggleMinimalMode()
            }
            
            // Exit hint overlay
            if showExitHint {
                VStack {
                    HStack {
                        Spacer()
                        
                        ExitMinimalModeHint(isPresented: $showExitHint) {
                            themeManager.toggleMinimalMode()
                        }
                        .padding(DesignSystem.spacingM)
                    }
                    
                    Spacer()
                }
            }
        }
    }

    private var emptyStateView: some View {
        VStack(spacing: DesignSystem.spacingM) {
            Image(systemName: "checkmark.circle")
                .font(.system(size: 48))
                .foregroundColor(themeManager.textTertiary)

            Text("没有任务")
                .font(.system(size: 16))
                .foregroundColor(themeManager.textSecondary)
            
            Text("双击退出极简模式")
                .font(.system(size: 12))
                .foregroundColor(themeManager.textTertiary)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .padding(DesignSystem.spacingXL)
    }
}

struct MinimalTaskRowView: View {
    let task: Task
    let onToggle: () -> Void
    
    @EnvironmentObject private var themeManager: ThemeManager
    @State private var isHovered = false

    var body: some View {
        HStack(spacing: DesignSystem.spacingS) {
            // Compact checkbox
            Button(action: onToggle) {
                ZStack {
                    Circle()
                        .stroke(themeManager.border, lineWidth: 1.5)
                        .frame(width: 16, height: 16)

                    if task.isCompleted {
                        Image(systemName: "checkmark")
                            .font(.system(size: 10, weight: .bold))
                            .foregroundColor(task.priority.color)
                    }
                }
                .frame(width: 32, height: 32)
                .contentShape(Rectangle())
            }
            .buttonStyle(.plain)

            // Priority dot (smaller)
            Circle()
                .fill(task.priority.color)
                .frame(width: 6, height: 6)

            // Task name
            Text(task.name)
                .font(.system(size: 13))
                .foregroundColor(task.isCompleted ? themeManager.textTertiary : themeManager.textPrimary)
                .strikethrough(task.isCompleted, color: themeManager.textTertiary)
                .lineLimit(1)

            Spacer(minLength: 0)
        }
        .padding(.horizontal, DesignSystem.spacingM)
        .padding(.vertical, DesignSystem.spacingS)
        .contentShape(Rectangle()) // 👈 关键：让整个区域都能响应悬停
        .background(isHovered ? themeManager.surfaceHover.opacity(0.5) : Color.clear)
        .onHover { hovering in
            withAnimation(.easeInOut(duration: 0.15)) {
                isHovered = hovering
            }
        }
    }
}

// Exit hint component
struct ExitMinimalModeHint: View {
    @Binding var isPresented: Bool
    let onExit: () -> Void
    
    @EnvironmentObject private var themeManager: ThemeManager
    @State private var opacity: Double = 0
    
    var body: some View {
        HStack(spacing: DesignSystem.spacingS) {
            Image(systemName: "info.circle")
                .font(.system(size: 12))
                .foregroundColor(themeManager.accent)
            
            Text("双击退出极简模式")
                .font(.system(size: 11))
                .foregroundColor(themeManager.textSecondary)
            
            Button(action: {
                withAnimation {
                    isPresented = false
                }
            }) {
                Image(systemName: "xmark")
                    .font(.system(size: 10))
                    .foregroundColor(themeManager.textTertiary)
            }
            .buttonStyle(.plain)
        }
        .padding(.horizontal, DesignSystem.spacingM)
        .padding(.vertical, DesignSystem.spacingS)
        .background(themeManager.backgroundSecondary.opacity(0.95))
        .cornerRadius(DesignSystem.cornerRadiusS)
        .overlay(
            RoundedRectangle(cornerRadius: DesignSystem.cornerRadiusS)
                .stroke(themeManager.border, lineWidth: 1)
        )
        .shadow(color: Color.black.opacity(0.1), radius: 4, x: 0, y: 2)
        .opacity(opacity)
        .onAppear {
            withAnimation(.easeIn(duration: 0.3)) {
                opacity = 1
            }
            
            // Auto-dismiss after 5 seconds
            DispatchQueue.main.asyncAfter(deadline: .now() + 5) {
                withAnimation(.easeOut(duration: 0.3)) {
                    isPresented = false
                }
            }
        }
        .onDisappear {
            opacity = 0
        }
    }
}

#Preview {
    let config = ModelConfiguration(isStoredInMemoryOnly: true)
    let container = try! ModelContainer(for: Task.self, configurations: config)
    let viewModel = TaskViewModel(modelContext: container.mainContext)
    
    return MinimalTaskListView(viewModel: viewModel)
        .environmentObject(ThemeManager())
}
