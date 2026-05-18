//
//  GlassContainerModifier.swift
//  Striv
//
//  Created by Thibault Giraudon on 12/05/2026.
//

import SwiftUI

struct GlassContainerModifier: ViewModifier {
    var shape: AnyShape?
    var cornerRadius: CGFloat = 16
    
    func body(content: Content) -> some View {
        if #available(iOS 26.0, *) {
            if let shape {
                content
                    .glassEffect(in: shape)
            } else {
                content
                    .glassEffect()
            }
        } else {
            content
                .background(.ultraThinMaterial)
                .clipShape(
                    shape.map { AnyShape($0) } ??
                    AnyShape(RoundedRectangle(cornerRadius: cornerRadius))
                )
        }
    }
}

extension View {
    func glassContainer(shape: AnyShape? = nil, cornerRadius: CGFloat = 16) -> some View {
        self.modifier(GlassContainerModifier(shape: shape, cornerRadius: cornerRadius))
    }
}
