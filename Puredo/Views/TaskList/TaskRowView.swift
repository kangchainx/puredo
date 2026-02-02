//
//  TaskRowView.swift
//  Puredo
//
//  Created by Chris Kang on 2026/2/1.
//

import SwiftUI

struct TaskRowView: View {
    let task: Task
    let onToggle: () -> Void
    var isPreview: Bool = false
    
    @EnvironmentObject private var themeManager: ThemeManager
    @State private var isHovered = false

    var body: some View {
        VStack(spacing: 0) {
            HStack(spacing: DesignSystem.spacingM) {
                // Custom circular checkbox
                Button(action: onToggle) {
                    ZStack {
                        Circle()
                            .stroke(themeManager.border, lineWidth: 2)
                            .frame(width: DesignSystem.checkboxSize, height: DesignSystem.checkboxSize)

                        if task.isCompleted {
                            Image(systemName: "checkmark")
                                .font(.system(size: 12, weight: .bold))
                                .foregroundColor(task.priority.color)
                        }
                    }
                    .frame(width: 44, height: 44) // Larger tap target
                    .contentShape(Rectangle()) // Make entire area tappable
                }
                .buttonStyle(.plain)

                // Priority dot
                Circle()
                    .fill(task.priority.color)
                    .frame(width: DesignSystem.priorityDotSize, height: DesignSystem.priorityDotSize)

                // Task name
                Text(task.name)
                    .font(.system(size: 15))
                    .foregroundColor(task.isCompleted ? themeManager.textTertiary : themeManager.textPrimary)
                    .strikethrough(task.isCompleted, color: themeManager.textTertiary)

                Spacer()
            }
            .padding(DesignSystem.spacingM)
            .background(isHovered && !isPreview ? themeManager.surfaceHover : Color.clear)
            
            Divider()
                .background(themeManager.divider)
        }
        .cornerRadius(DesignSystem.cornerRadiusS)
        .onHover { hovering in
            withAnimation(DesignSystem.springAnimation) {
                isHovered = hovering
            }
        }
    }
}
