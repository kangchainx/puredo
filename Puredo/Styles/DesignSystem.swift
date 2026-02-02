//
//  DesignSystem.swift
//  Puredo
//
//  Created by Chris Kang on 2026/2/1.
//

import SwiftUI

struct DesignSystem {
    // Spacing
    static let spacingXS: CGFloat = 4
    static let spacingS: CGFloat = 8
    static let spacingM: CGFloat = 12
    static let spacingL: CGFloat = 16
    static let spacingXL: CGFloat = 24
    static let spacingXXL: CGFloat = 32

    // Corner Radius
    static let cornerRadiusS: CGFloat = 8
    static let cornerRadiusM: CGFloat = 12
    static let cornerRadiusL: CGFloat = 16

    // Sizes
    static let sidebarWidth: CGFloat = 200
    static let priorityDotSize: CGFloat = 8
    static let checkboxSize: CGFloat = 20

    // Animations
    static let springAnimation = Animation.spring(response: 0.3, dampingFraction: 0.7)

    // Opacity
    static let glassOpacity: Double = 0.1
    static let strokeOpacity: Double = 0.2
    static let secondaryTextOpacity: Double = 0.6
    static let tertiaryTextOpacity: Double = 0.4
}
