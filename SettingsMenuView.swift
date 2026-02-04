//
//  SettingsMenuView.swift
//  Puredo
//
//  Created by Codex on 2026/2/4.
//

import SwiftUI

struct SettingsMenuView: View {
    @EnvironmentObject private var themeManager: ThemeManager
    
    var body: some View {
        VStack(alignment: .leading, spacing: DesignSystem.spacingM) {
            // Header
            Text("设置")
                .font(.system(size: 14, weight: .semibold))
                .foregroundColor(themeManager.textPrimary)
                .padding(.bottom, DesignSystem.spacingXS)
            
            Divider()
                .background(themeManager.divider)
            
            // Auto minimal mode on pin setting
            HStack(alignment: .top, spacing: DesignSystem.spacingM) {
                VStack(alignment: .leading, spacing: 4) {
                    Text("置顶后切换至极简模式")
                        .font(.system(size: 12))
                        .foregroundColor(themeManager.textPrimary)
                    
                    Text("窗口置顶时自动进入极简模式")
                        .font(.system(size: 10))
                        .foregroundColor(themeManager.textSecondary)
                }
                
                Spacer()
                
                Toggle("", isOn: Binding(
                    get: { themeManager.autoMinimalModeOnPin },
                    set: { _ in themeManager.toggleAutoMinimalModeOnPin() }
                ))
                .labelsHidden()
                .toggleStyle(.switch)
                .controlSize(.small)
            }
        }
        .padding(DesignSystem.spacingM)
        .frame(width: 280)
        .background(themeManager.backgroundSecondary)
        .cornerRadius(DesignSystem.cornerRadiusM)
        .overlay(
            RoundedRectangle(cornerRadius: DesignSystem.cornerRadiusM)
                .stroke(themeManager.border, lineWidth: 1)
        )
        .shadow(color: Color.black.opacity(0.15), radius: 8, x: 0, y: 4)
    }
}

#Preview {
    SettingsMenuView()
        .environmentObject(ThemeManager())
}
