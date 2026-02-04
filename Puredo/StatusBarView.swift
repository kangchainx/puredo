//
//  StatusBarView.swift
//  Puredo
//
//  Created by Codex on 2026/2/4.
//

import SwiftUI
import SwiftData

struct StatusBarView: View {
    @Bindable var viewModel: TaskViewModel
    @EnvironmentObject private var themeManager: ThemeManager
    @State private var showHistorySheet = false
    
    var body: some View {
        HStack {
            // 左侧：显示统计信息
            HStack(spacing: DesignSystem.spacingS) {
                Text("\(viewModel.completedTasksCount)/\(viewModel.totalTasksCount)")
                    .font(.system(size: 11))
                    .foregroundColor(themeManager.textSecondary)
            }
            
            Spacer()
            
            // 右侧：历史按钮
            Button(action: {
                showHistorySheet = true
            }) {
                HStack(spacing: 4) {
                    Image(systemName: "clock.arrow.circlepath")
                        .font(.system(size: 11))
                    Text("历史")
                        .font(.system(size: 11))
                }
                .foregroundColor(themeManager.textSecondary)
                .padding(.horizontal, 8)
                .padding(.vertical, 4)
                .background(themeManager.surface)
                .clipShape(RoundedRectangle(cornerRadius: 6))
            }
            .buttonStyle(.plain)
            .onHover { isHovered in
                if isHovered {
                    NSCursor.pointingHand.push()
                } else {
                    NSCursor.pop()
                }
            }
        }
        .padding(.horizontal, DesignSystem.spacingL)
        .padding(.vertical, DesignSystem.spacingM)
        .background(statusBarBackground)
        .sheet(isPresented: $showHistorySheet) {
            TaskHistoryView(viewModel: viewModel)
        }
    }
    
    private var statusBarBackground: some ShapeStyle {
        themeManager.surface.opacity(0.5)
    }
}

#Preview {
    let config = ModelConfiguration(isStoredInMemoryOnly: true)
    let container = try! ModelContainer(for: Task.self, configurations: config)
    let viewModel = TaskViewModel(modelContext: container.mainContext)
    
    StatusBarView(viewModel: viewModel)
        .environmentObject(ThemeManager())
        .frame(width: 400)
}
