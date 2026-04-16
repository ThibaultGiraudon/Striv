//
//  StrivWidgetBundle.swift
//  StrivWidget
//
//  Created by Thibault Giraudon on 15/04/2026.
//

import WidgetKit
import SwiftUI

@main
struct StrivWidgetBundle: WidgetBundle {
    var body: some Widget {
        DistanceWidget()
        StreakWidget()
        PRsWidget()
        LastRunWidget()
    }
}
