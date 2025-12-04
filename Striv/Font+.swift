//
//  Font+.swift
//  FitBoard
//
//  Created by Thibault Giraudon on 23/10/2025.
//

import SwiftUI

extension Font {
    static func switzer(size: CGFloat, weight: Font.Weight = .regular, italic: Bool = false, relativeTo style: Font.TextStyle = .body) -> Font {
        let name = italic ? "SwitzerVariable-Italic" : "SwitzerVariable-Regular"
        return .custom(name, size: size, relativeTo: style)
            .weight(weight)
    }
}
