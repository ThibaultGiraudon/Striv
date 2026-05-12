//
//  GlassContainerModifier.swift
//  Striv
//
//  Created by Thibault Giraudon on 12/05/2026.
//

import SwiftUI

struct GlassContainerModifier: ViewModifier {
    var cornerRadius: CGFloat = 16

    func body(content: Content) -> some View {
        if #available(iOS 26.0, *) {
            content
                .glassEffect(in: .rect(cornerRadius: 16))
        } else {
            content
                .background(.ultraThinMaterial)
                .clipShape(RoundedRectangle(cornerRadius: cornerRadius))
        }
    }
}

extension View {
    func glassContainer(cornerRadius: CGFloat = 16) -> some View {
        self.modifier(GlassContainerModifier(cornerRadius: cornerRadius))
    }
}
