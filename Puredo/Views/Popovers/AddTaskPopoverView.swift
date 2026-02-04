//
//  AddTaskPopoverView.swift
//  Puredo
//
//  Created by Chris Kang on 2026/2/1.
//

import SwiftUI
import SwiftData

struct AddTaskPopoverView: View {
    @Bindable var viewModel: TaskViewModel
    @Binding var isPresented: Bool
    @EnvironmentObject private var themeManager: ThemeManager

    @State private var taskName: String = ""
    @State private var taskPriority: TaskPriority = .blue
    @FocusState private var isInputFocused: Bool

    var body: some View {
        VStack(alignment: .leading, spacing: DesignSystem.spacingL) {
            // Header with title and shortcuts hint
            HStack {
                Text("新建任务")
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundColor(themeManager.textPrimary)
                
                Spacer()
                
                // Shortcuts hint in top-right corner
                HStack(spacing: 4) {
                    Text("⌘1")
                        .font(.system(size: 10, weight: .medium))
                        .foregroundColor(themeManager.textSecondary)
                        .padding(.horizontal, 5)
                        .padding(.vertical, 2)
                        .background(themeManager.surface)
                        .cornerRadius(3)
                    
                    Text("⌘2")
                        .font(.system(size: 10, weight: .medium))
                        .foregroundColor(themeManager.textSecondary)
                        .padding(.horizontal, 5)
                        .padding(.vertical, 2)
                        .background(themeManager.surface)
                        .cornerRadius(3)
                    
                    Text("⌘3")
                        .font(.system(size: 10, weight: .medium))
                        .foregroundColor(themeManager.textSecondary)
                        .padding(.horizontal, 5)
                        .padding(.vertical, 2)
                        .background(themeManager.surface)
                        .cornerRadius(3)
                }
            }

            HStack(spacing: DesignSystem.spacingM) {
                // Three color icons with keyboard shortcuts
                HStack(spacing: DesignSystem.spacingM) {
                    ForEach(Array(TaskPriority.allCases.enumerated()), id: \.element) { index, priority in
                        Button(action: {
                            withAnimation(DesignSystem.springAnimation) {
                                taskPriority = priority
                            }
                        }) {
                            Circle()
                                .fill(priority.color)
                                .frame(width: 20, height: 20)
                                .overlay(
                                    Circle()
                                        .stroke(themeManager.textPrimary, lineWidth: taskPriority == priority ? 2 : 0)
                                )
                                .scaleEffect(taskPriority == priority ? 1.15 : 1.0)
                        }
                        .buttonStyle(.plain)
                        .keyboardShortcut(KeyEquivalent(Character(String(index + 1))), modifiers: .command)
                    }
                }

                // Task name input
                TextField("输入任务名称", text: $taskName)
                    .textFieldStyle(.plain)
                    .foregroundColor(themeManager.textPrimary)
                    .focused($isInputFocused)
                    .onSubmit {
                        if !taskName.isEmpty {
                            addTask()
                        }
                    }
            }
            .padding(DesignSystem.spacingM)
            .background(themeManager.surface)
            .cornerRadius(DesignSystem.cornerRadiusM)
            .overlay(
                RoundedRectangle(cornerRadius: DesignSystem.cornerRadiusM)
                    .stroke(themeManager.border, lineWidth: 1)
            )

            HStack(spacing: DesignSystem.spacingM) {
                Button("取消") {
                    isPresented = false
                }
                .buttonStyle(.plain)
                .foregroundColor(themeManager.textSecondary)
                .keyboardShortcut(.cancelAction)

                Spacer()

                Button("添加") {
                    addTask()
                }
                .buttonStyle(.plain)
                .foregroundColor(themeManager.accent)
                .disabled(taskName.isEmpty)
                .keyboardShortcut(.defaultAction)
            }
        }
        .padding(DesignSystem.spacingL)
        .frame(width: 400)
        .background(themeManager.backgroundSecondary)
        .cornerRadius(DesignSystem.cornerRadiusL)
        .overlay(
            RoundedRectangle(cornerRadius: DesignSystem.cornerRadiusL)
                .stroke(themeManager.border, lineWidth: 1)
        )
        .onAppear {
            isInputFocused = true
        }
    }

    private func addTask() {
        guard !taskName.isEmpty else { return }

        let task = Task(
            name: taskName,
            date: Date(), // Always today
            priority: taskPriority
        )

        withAnimation(DesignSystem.springAnimation) {
            viewModel.addTask(task)
        }

        isPresented = false
    }
}

#Preview {
    let config = ModelConfiguration(isStoredInMemoryOnly: true)
    let container = try! ModelContainer(for: Task.self, configurations: config)
    let viewModel = TaskViewModel(modelContext: container.mainContext)
    
    return AddTaskPopoverView(viewModel: viewModel, isPresented: .constant(true))
        .environmentObject(ThemeManager())
}
