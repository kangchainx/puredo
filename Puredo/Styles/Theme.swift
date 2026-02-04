//
//  Theme.swift
//  Puredo
//
//  Created by Chris Kang on 2026/2/2.
//

import SwiftUI
import Combine

enum AppTheme: String, CaseIterable {
    case dark = "dark"
    case light = "light"
    
    var displayName: String {
        switch self {
        case .dark: return "深色"
        case .light: return "浅色"
        }
    }
}

// Theme Manager using AppStorage
class ThemeManager: ObservableObject {
    @Published var currentTheme: AppTheme = .dark
    @Published var isMinimalMode: Bool = false
    @Published var autoMinimalModeOnPin: Bool = false
    
    init() {
        if let savedTheme = UserDefaults.standard.string(forKey: "appTheme"),
           let theme = AppTheme(rawValue: savedTheme) {
            self.currentTheme = theme
        } else {
            self.currentTheme = .dark
        }
        
        self.isMinimalMode = UserDefaults.standard.bool(forKey: "isMinimalMode")
        self.autoMinimalModeOnPin = UserDefaults.standard.bool(forKey: "autoMinimalModeOnPin")
    }
    
    func toggleAutoMinimalModeOnPin() {
        autoMinimalModeOnPin.toggle()
        UserDefaults.standard.set(autoMinimalModeOnPin, forKey: "autoMinimalModeOnPin")
    }
    
    private func saveTheme() {
        UserDefaults.standard.set(currentTheme.rawValue, forKey: "appTheme")
    }
    
    func toggleMinimalMode() {
        withAnimation(.easeInOut(duration: 0.3)) {
            isMinimalMode.toggle()
        }
        UserDefaults.standard.set(isMinimalMode, forKey: "isMinimalMode")
    }
    
    // Cursor Dark Theme Colors
    struct CursorDark {
        static let background = Color(hex: "#1e1e1e")
        static let backgroundSecondary = Color(hex: "#252525")
        static let backgroundTertiary = Color(hex: "#2d2d2d")
        static let surface = Color(hex: "#2a2a2a")
        static let surfaceHover = Color(hex: "#323232")
        static let border = Color(hex: "#3e3e3e")
        static let accent = Color(hex: "#0078d4")
        static let accentHover = Color(hex: "#1a86e0")
        static let textPrimary = Color(hex: "#d4d4d4")
        static let textSecondary = Color(hex: "#9d9d9d")
        static let textTertiary = Color(hex: "#6e6e6e")
        static let divider = Color(hex: "#454545")
    }
    
    // Apple Light Theme Colors
    struct AppleLight {
        static let background = Color.white
        static let backgroundSecondary = Color.white  // Header background - pure white
        static let backgroundTertiary = Color(hex: "#f5f5f5")
        static let surface = Color.white  // Input fields - pure white
        static let surfaceHover = Color(hex: "#f5f5f5")
        static let border = Color(hex: "#e0e0e0")
        static let accent = Color(hex: "#007aff")
        static let accentHover = Color(hex: "#0051d5")
        static let textPrimary = Color(hex: "#000000")
        static let textSecondary = Color(hex: "#6e6e73")
        static let textTertiary = Color(hex: "#aeaeb2")
        static let divider = Color(hex: "#e0e0e0")
    }
    
    // Dynamic colors based on current theme
    var background: Color {
        currentTheme == .dark ? CursorDark.background : AppleLight.background
    }
    
    var backgroundSecondary: Color {
        currentTheme == .dark ? CursorDark.backgroundSecondary : AppleLight.backgroundSecondary
    }
    
    var backgroundTertiary: Color {
        currentTheme == .dark ? CursorDark.backgroundTertiary : AppleLight.backgroundTertiary
    }
    
    var surface: Color {
        currentTheme == .dark ? CursorDark.surface : AppleLight.surface
    }
    
    var surfaceHover: Color {
        currentTheme == .dark ? CursorDark.surfaceHover : AppleLight.surfaceHover
    }
    
    var border: Color {
        currentTheme == .dark ? CursorDark.border : AppleLight.border
    }
    
    var accent: Color {
        currentTheme == .dark ? CursorDark.accent : AppleLight.accent
    }
    
    var accentHover: Color {
        currentTheme == .dark ? CursorDark.accentHover : AppleLight.accentHover
    }
    
    var textPrimary: Color {
        currentTheme == .dark ? CursorDark.textPrimary : AppleLight.textPrimary
    }
    
    var textSecondary: Color {
        currentTheme == .dark ? CursorDark.textSecondary : AppleLight.textSecondary
    }
    
    var textTertiary: Color {
        currentTheme == .dark ? CursorDark.textTertiary : AppleLight.textTertiary
    }
    
    var divider: Color {
        currentTheme == .dark ? CursorDark.divider : AppleLight.divider
    }
    
    func toggle() {
        withAnimation(.easeInOut(duration: 0.3)) {
            currentTheme = currentTheme == .dark ? .light : .dark
        }
        saveTheme()
    }
}
