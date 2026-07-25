//
//  WorkoutOverview.swift
//  Striv
//
//  Created by Thibault Giraudon on 22/07/2026.
//

import SwiftUI

struct CardModifier: ViewModifier {
    var color: Color
    
    func body(content: Content) -> some View {
        content
            .padding()
            .background {
                RoundedRectangle(cornerRadius: 16)
                    .foregroundStyle(color)
            }
    }
}

extension View {
    func cardStyle(_ color: Color = .customPrimary) -> some View {
        modifier(CardModifier(color: color))
    }
}

struct WorkoutOverview: View {
    let workout: Workout
    @StateObject private var workoutDetailVM: WorkoutDetailViewModel
    @Environment(\.modelContext) var modelContext
    
    init(workout: Workout, errorPresenter: ErrorPresenter) {
        self.workout = workout
        self._workoutDetailVM = StateObject(wrappedValue: .init(workout: workout, healthKitHelper: HealthKitHelper(), errorPresenter: errorPresenter))
    }
    
    var body: some View {
        VStack {
            StatsCard(workout: workout)
            .task {
                workoutDetailVM.setContext(context: modelContext)
                await workoutDetailVM.prepareData()
            }

            SplitsCard(workout: workout)
            
            PaceCard(workout: workout, workoutDetailVM: workoutDetailVM)
            
            HeartRateCard(workout: workout, workoutDetailVM: workoutDetailVM)
            
            ElevationCard(workout: workout, workoutDetailVM: workoutDetailVM)
            
            PowerCard(workout: workout, workoutDetailVM: workoutDetailVM)
            
            OverlayCard(workout: workout)
        }
    }
}

#Preview {
    ScrollView {
        WorkoutOverview(workout: Workout(id: UUID(), date: .now, distance: 12129, duration: .init(4400), hr: 171, kcal: 949, elevation: 275, cadence: 151, power: 221), errorPresenter: .init())
    }
}
