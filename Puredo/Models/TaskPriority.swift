//
//  TaskPriority.swift
//  Puredo
//
//  Created by Chris Kang on 2026/2/1.
//

import SwiftUI

enum TaskPriority: String, Codable, CaseIterable {
    case red
    case yellow
    case blue
    
    var sortOrder: Int {
        switch self {
        case .red:
            return 0
        case .yellow:
            return 1
        case .blue:
            return 2
        }
    }

    var color: Color {
        switch self {
        case .red:
            return Color(hex: "#FF3B30")
        case .yellow:
            return Color(hex: "#FFCC00")
        case .blue:
            return Color(hex: "#007AFF")
        }
    }

    var displayName: String {
        switch self {
        case .red:
            return "红色"
        case .yellow:
            return "黄色"
        case .blue:
            return "蓝色"
        }
    }
}
