//
//  GoalsView.swift
//  Striv
//
//  Created by Thibault Giraudon on 25/07/2026.
//

import SwiftUI
import SwiftData

struct GoalsView: View {    
    @Query private var goals: [Goal]
    @ObservedObject var runnerProfileVM: RunnerProfileViewModel
    @ObservedObject var goalsVM: GoalsViewModel
    var body: some View {
        VStack(alignment: .center) {
            if let mainGoal = goalsVM.getMainGoal() {
                HStack {
                    VStack(alignment: .leading) {
                        Text("Objectif principal")
                            .font(.title.bold())
                        Text("Ton objectif de référence actuel.")
                    }
                    Spacer()
                }
                NavigationLink {
                    DefineGoalView(
                        goal: goalsVM.getGoal(for: mainGoal.distance),
                        distance: mainGoal.distance,
                        runnerProfileVM: runnerProfileVM,
                        goalsVM: goalsVM)
                } label: {
                    MainGoalView(mainGoal: mainGoal)
                }
                
                Spacer()
            }
            
            HStack {
                VStack(alignment: .leading) {
                    Text("Mes objectifs")
                        .font(.title.bold())
                    Text("Définis, consulte et gère tout tes objectifs.")
                }
                Spacer()
            }
            
            ForEach(PresetDistance.allCases, id: \.self) { distance in
                NavigationLink {
                    DefineGoalView(
                        goal: goalsVM.getGoal(for: distance),
                        distance: distance,
                        runnerProfileVM: runnerProfileVM,
                        goalsVM: goalsVM)
                } label: {
                    GoalRowView(goal: goalsVM.getGoal(for: distance), distance: distance)
                }
            }
            
            Spacer()
            
            if goalsVM.getMainGoal() == nil {
                GoalsEmptyView()
            }
        }
        .padding()
        .background {
            Color.background
                .ignoresSafeArea()
        }
        .foregroundStyle(.primaryText)
        .onAppear {
            goalsVM.goals = goals
        }
    }
}

#Preview {
    GoalsView(runnerProfileVM: .init(errorPresenter: .init()), goalsVM: .init(errorPresenter: .init()))
}
