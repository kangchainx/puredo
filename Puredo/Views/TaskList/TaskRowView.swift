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
    let onDelete: (() -> Void)?
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

                Spacer(minLength: 0)

                Button(action: {
                    onDelete?()
                }) {
                    Image(systemName: "trash")
                        .font(.system(size: 12, weight: .semibold))
                        .foregroundColor(.red)
                        .frame(width: 28, height: 28)
                        .background(themeManager.surface)
                        .clipShape(Circle())
                }
                .buttonStyle(.plain)
                .opacity(isHovered && !isPreview ? 1 : 0)
                .scaleEffect(isHovered && !isPreview ? 1 : 0.9)
                .allowsHitTesting((isHovered && !isPreview) && onDelete != nil)
                .animation(.easeInOut(duration: 0.15), value: isHovered)
            }
            .padding(DesignSystem.spacingM)
            .contentShape(Rectangle()) // 👈 关键：让整个 HStack 区域都能响应悬停
            .background(isHovered && !isPreview ? themeManager.surfaceHover : Color.clear)
            .onHover { hovering in
                withAnimation(DesignSystem.springAnimation) {
                    isHovered = hovering
                }
            }
            
            Divider()
                .background(themeManager.divider)
        }
        .cornerRadius(DesignSystem.cornerRadiusS)
    }
}
