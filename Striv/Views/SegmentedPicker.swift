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
                let isSelected = selection == item
                
                Text(title(item))
                    .frame(maxWidth: .infinity)
                    .lineLimit(1)
                    .padding(.vertical, size)
                    .background {
                        if isSelected {
                            Capsule()
                                .fill(.teal)
                                .matchedGeometryEffect(id: "ACTIVETAB", in: animation)
                        }
                    }
                    .foregroundColor(isSelected ? .background : .primaryText)
                    .contentShape(Capsule())
                    .onTapGesture {
                        withAnimation(.snappy) {
                            selection = item
                        }
                    }
                    .accessibilityElement()
                    .accessibilityAddTraits(.isButton)
                    .accessibilityLabel(Text(title(item)))
                    .accessibilityHint(isSelected ? "" : "Double tap pour sélectionner")
                    .accessibilityAddTraits(isSelected ? [.isSelected] : [])
                    .accessibilityAction {
                        withAnimation(.snappy) {
                            selection = item
                        }
                    }
            }
        }
        .padding(4)
        .background {
            Capsule()
                .foregroundStyle(.customPrimary)
        }
        .accessibilityElement(children: .contain)
        .accessibilityLabel("Sélecteur")
        .accessibilityHint("Choisissez une option")
        .accessibilityValue(title(selection))
    }
}

#Preview {
    @Previewable @State var selection: GoalType = .distance
    SegmentedPicker(items: GoalType.allCases, title: { $0.rawValue }, selection: $selection)
}
