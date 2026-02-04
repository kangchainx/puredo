//
//  MinimalModeNotification.swift
//  Puredo
//
//  Created by Chris Kang on 2026/2/3.
//

import SwiftUI
import AppKit

struct MinimalModeNotification: View {
    @Binding var isPresented: Bool
    let onConfirm: () -> Void
    let onCancel: () -> Void
    
    @EnvironmentObject private var themeManager: ThemeManager
    @State private var offsetX: CGFloat = 400
    @State private var windowWidth: CGFloat = 420
    
    // Computed notification width based on window size
    private var notificationWidth: CGFloat {
        // Use 90% of window width, but clamp between 280-380
        let calculatedWidth = windowWidth * 0.9
        return min(max(calculatedWidth, 280), 380)
    }
    
    var body: some View {
        HStack(spacing: DesignSystem.spacingM) {
            // Icon
            Image(systemName: "sparkles")
                .font(.system(size: 20))
                .foregroundColor(themeManager.accent)
            
            // Message
            VStack(alignment: .leading, spacing: 4) {
                Text("切换至极简模式？")
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundColor(themeManager.textPrimary)
                
                Text("隐藏所有操作按钮，专注任务本身")
                    .font(.system(size: 12))
                    .foregroundColor(themeManager.textSecondary)
            }
            
            Spacer()
            
            // Buttons
            HStack(spacing: DesignSystem.spacingS) {
                Button("取消") {
                    dismissNotification()
                    onCancel()
                }
                .buttonStyle(.plain)
                .foregroundColor(themeManager.textSecondary)
                .padding(.horizontal, 12)
                .padding(.vertical, 6)
                .background(themeManager.surface)
                .cornerRadius(6)
                
                Button("确认") {
                    dismissNotification()
                    onConfirm()
                }
                .buttonStyle(.plain)
                .foregroundColor(.white)
                .padding(.horizontal, 12)
                .padding(.vertical, 6)
                .background(themeManager.accent)
                .cornerRadius(6)
            }
        }
        .padding(DesignSystem.spacingL)
        .background(themeManager.backgroundSecondary)
        .cornerRadius(DesignSystem.cornerRadiusM)
        .overlay(
            RoundedRectangle(cornerRadius: DesignSystem.cornerRadiusM)
                .stroke(themeManager.border, lineWidth: 1)
        )
        .shadow(color: Color.black.opacity(0.2), radius: 10, x: 0, y: 4)
        .frame(width: notificationWidth)
        .offset(x: offsetX)
        .onAppear {
            // Get current window width
            if let window = NSApplication.shared.keyWindow ?? NSApplication.shared.windows.first {
                windowWidth = window.frame.width
            }
            
            withAnimation(.spring(response: 0.5, dampingFraction: 0.8)) {
                offsetX = 0
            }
        }
    }
    
    private func dismissNotification() {
        withAnimation(.spring(response: 0.4, dampingFraction: 0.8)) {
            offsetX = notificationWidth
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) {
            isPresented = false
        }
    }
}

#Preview {
    ZStack {
        Color.gray.opacity(0.3)
        
        VStack {
            Spacer()
            
            HStack {
                Spacer()
                
                MinimalModeNotification(
                    isPresented: .constant(true),
                    onConfirm: { print("Confirmed") },
                    onCancel: { print("Cancelled") }
                )
                .padding()
            }
        }
    }
    .environmentObject(ThemeManager())
}
