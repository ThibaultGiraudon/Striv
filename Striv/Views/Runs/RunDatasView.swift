//
//  RunDatasView.swift
//  Striv
//
//  Created by Thibault Giraudon on 22/07/2026.
//

import SwiftUI

enum WorkoutDetailTab: String, CaseIterable {
    case overview = "Aperçu"
    case charts = "Graphiques"
    case info = "Info"
    case analysis = "Analyse"
}

struct RunDatasView: View {
    let workout: Workout
    
    @State private var selectedTab: WorkoutDetailTab = .overview
    var body: some View {
        VStack {
            SegmentedPicker(items: WorkoutDetailTab.allCases, title: { $0.rawValue }, selection: $selectedTab, size: 10)
            
            ScrollView {
                switch selectedTab {
                case .overview:
                    WorkoutOverview(workout: workout)
                case .charts:
                    MetricsOverlayChartView(workout: workout)
                case .info:
                    EmptyView()
                case .analysis:
                    EmptyView()
                }
            }
        }
        .padding()
    }
}

#Preview {
    RunDatasView(workout: Workout(id: UUID(), date: .now, distance: 12129, duration: .init(4400), hr: 171, kcal: 949, elevation: 275, cadence: 151, power: 221))
}
