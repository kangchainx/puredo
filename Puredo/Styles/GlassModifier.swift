//
//  GlassModifier.swift
//  Puredo
//
//  Created by Chris Kang on 2026/2/1.
//

import SwiftUI

struct GlassModifier: ViewModifier {
    var cornerRadius: CGFloat = DesignSystem.cornerRadiusM
    var isStatic: Bool = false

    func body(content: Content) -> some View {
        Group {
            if isStatic {
                content
                    .background(Color.white.opacity(DesignSystem.glassOpacity))
                    .background(Color.black.opacity(0.8))
            } else {
                content
                    .background(Color.white.opacity(DesignSystem.glassOpacity))
                    .background(Material.ultraThin)
            }
        }
        .cornerRadius(cornerRadius)
        .overlay(
            RoundedRectangle(cornerRadius: cornerRadius)
                .stroke(Color.white.opacity(DesignSystem.strokeOpacity), lineWidth: 1)
        )
    }
}

extension View {
    func glassEffect(cornerRadius: CGFloat = DesignSystem.cornerRadiusM, isStatic: Bool = false) -> some View {
        modifier(GlassModifier(cornerRadius: cornerRadius, isStatic: isStatic))
    }
}
