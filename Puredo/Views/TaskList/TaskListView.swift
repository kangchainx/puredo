//
//  TaskListView.swift
//  Puredo
//
//  Created by Chris Kang on 2026/2/1.
//

import SwiftUI

struct TaskListView: View {
    @Bindable var viewModel: TaskViewModel
    @EnvironmentObject private var themeManager: ThemeManager

    var body: some View {
        ScrollView {
            if viewModel.filteredTasks.isEmpty {
                emptyStateView
            } else {
                LazyVStack(spacing: DesignSystem.spacingM) {
                    ForEach(viewModel.filteredTasks) { task in
                        TaskRowView(task: task) {
                            withAnimation(DesignSystem.springAnimation) {
                                viewModel.toggleComplete(task)
                            }
                        }
                    }
                }
                .padding(DesignSystem.spacingL)
            }
        }
    }

    private var emptyStateView: some View {
        VStack(spacing: DesignSystem.spacingL) {
            Image(systemName: "checkmark.circle")
                .font(.system(size: 64))
                .foregroundColor(themeManager.textTertiary)

            Text(emptyStateText)
                .font(.system(size: 18))
                .foregroundColor(themeManager.textSecondary)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .padding(DesignSystem.spacingXXL)
    }

    private var emptyStateText: String {
        if !viewModel.searchText.isEmpty {
            return "未找到任务"
        } else {
            return "今天没有任务"
        }
    }
}
