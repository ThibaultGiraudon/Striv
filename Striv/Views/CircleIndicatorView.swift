//
//  CircleIndicatorView.swift
//  Striv
//
//  Created by Thibault Giraudon on 12/03/2026.
//

import SwiftUI

struct CircleIndicatorView: View {
    var current: Double
    var target: Double
    var color: Color = .teal
    var size: CGFloat = 100
    var lineWidth: CGFloat = 15
    
    var body: some View {
        ZStack {
            Circle()
                .stroke(lineWidth: lineWidth)
                .frame(width: size)
                .foregroundStyle(.gray.opacity(0.2))
            Circle()
                .trim(from: 0.0, to: CGFloat(current / target))
                .stroke(style: StrokeStyle(lineWidth: lineWidth, lineCap: .round))
                .fill(.teal)
                .frame(width: size)
                .rotationEffect(Angle(degrees: 270.0))
        }
    }
}

#Preview {
    CircleIndicatorView(current: 1, target: 20)
}
