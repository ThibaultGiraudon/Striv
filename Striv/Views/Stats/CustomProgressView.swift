//
//  CustomProgressView.swift
//  Striv
//
//  Created by Thibault Giraudon on 02/04/2026.
//

import SwiftUI

struct CustomProgressView: View {
    var value: Double
    var total: Double
    
    var body: some View {
        GeometryReader { geo in
            let width = geo.size.width
            Capsule()
                .foregroundStyle(.quinary)
                .glassEffect()
            
            Capsule()
                .fill(.teal)
                .frame(width: value * width / total)
        }
        .frame(height: 12)
    }
}

#Preview {
    CustomProgressView(value: 12.4, total: 25.0)
}
