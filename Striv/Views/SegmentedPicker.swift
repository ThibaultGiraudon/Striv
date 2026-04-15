//
//  SegmentedPicker.swift
//  Striv
//
//  Created by Thibault Giraudon on 14/04/2026.
//

import SwiftUI

struct SegmentedPicker<T: Hashable>: View {
    
    let items: [T]
    let title: (T) -> String
    @Binding var selection: T
    var size: CGFloat = 20
    @Namespace var animation
    
    var body: some View {
        HStack(spacing: 8) {
            ForEach(items, id: \.self) { item in
                Text(title(item))
                    .frame(maxWidth: .infinity)
                    .lineLimit(1)
                    .padding(.vertical, size)
                    .background {
                        if selection == item {
                            Capsule()
                                .fill(.teal)
                                .matchedGeometryEffect(id: "ACTIVETAB", in: animation)
                        }
                    }
                    .foregroundColor(selection == item ? .background : .primaryText)
                    .onTapGesture {
                        withAnimation(.snappy) {
                            selection = item
                        }
                    }
            }
        }
        .background {
            Capsule()
                .foregroundStyle(.customPrimary)
        }
    }
}

#Preview {
    @Previewable @State var selection: GoalType = .distance
    SegmentedPicker(items: GoalType.allCases, title: { $0.rawValue }, selection: $selection)
}
