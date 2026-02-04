//
//  SettingsPopoverView.swift
//  Puredo
//
//  Created by Chris Kang on 2026/2/3.
//

import SwiftUI

struct SettingsPopoverView: View {
    @EnvironmentObject private var themeManager: ThemeManager
    @Binding var isPresented: Bool
    
    var body: some View {
        VStack(alignment: .leading, spacing: DesignSystem.spacingL) {
            // Header
            Text("设置")
                .font(.system(size: 16, weight: .semibold))
                .foregroundColor(themeManager.textPrimary)
            
            Divider()
                .background(themeManager.divider)
            
            // Settings options
            VStack(alignment: .leading, spacing: DesignSystem.spacingM) {
                Toggle(isOn: $themeManager.autoMinimalModeOnPin) {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("置顶后切换至极简模式")
                            .font(.system(size: 13))
                            .foregroundColor(themeManager.textPrimary)
                        
                        Text("启用后，点击置顶按钮将自动进入极简模式")
                            .font(.system(size: 11))
                            .foregroundColor(themeManager.textSecondary)
                    }
                }
                .toggleStyle(.switch)
            }
        }
        .padding(DesignSystem.spacingL)
        .frame(width: 320)
        .background(themeManager.backgroundSecondary)
        .cornerRadius(DesignSystem.cornerRadiusM)
        .overlay(
            RoundedRectangle(cornerRadius: DesignSystem.cornerRadiusM)
                .stroke(themeManager.border, lineWidth: 1)
        )
    }
}

#Preview {
    SettingsPopoverView(isPresented: .constant(true))
        .environmentObject(ThemeManager())
}
