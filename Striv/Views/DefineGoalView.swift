//
//  DefineGoalView.swift
//  Striv
//
//  Created by Thibault Giraudon on 10/04/2026.
//

import SwiftUI
import SwiftData

struct DefineGoalView: View {
    @ObservedObject var runnerProfileVM: RunnerProfileViewModel
    
    @Query private var profiles: [RunnerProfile]
    @StateObject private var defineGoalVM = DefineGoalViewModel()
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading) {
                Text("Définir objectif")
                    .font(.title.bold())
                Text("Choisi ton objectif de course.")
                
                SegmentedPicker(items: GoalType.allCases, title: { $0.rawValue }, selection: $defineGoalVM.goalType, size: 10)
                    .font(.title2)
                    .padding(.vertical)
                
                SegmentedPicker(items: DistanceType.allCases, title: { $0.title }, selection: $defineGoalVM.distanceType, size: 10)
                
                Button {
                    defineGoalVM.distanceType = .custom(defineGoalVM.customDistance)
                } label: {
                    Text("Distance personnalisée")
                        .foregroundStyle(.white)
                }
                .frame(maxWidth: .infinity)
                .padding(10)
                .background {
                    Capsule()
                        .fill(
                            defineGoalVM.distanceType.title == "Distance personnalisée" ? .teal : .customPrimary
                        )
                }
                .padding(.bottom)
                
                if defineGoalVM.distanceType.title == "Distance personnalisée" {
                    CustomTextField("Distance en m", systemName: "flag.checkered", value: $defineGoalVM.customDistance)
                        .onSubmit {
                            defineGoalVM.distanceType = .custom(defineGoalVM.customDistance)
                        }
                }
                
                VStack(alignment: .center) {
                    Text(defineGoalVM.formatTime)
                        .font(.system(size: 50).bold())
                    Text("Objectif pour \(Int(defineGoalVM.distanceType.meters / 1000)) km")
                    Slider(value: $defineGoalVM.time, in: Double(defineGoalVM.timeBounds.min)...Double(defineGoalVM.timeBounds.max))
                }
                .frame(maxWidth: .infinity, alignment: .center)
                .padding()
                .background {
                    RoundedRectangle(cornerRadius: 16)
                        .foregroundStyle(Color.customPrimary)
                }
                HStack {
                    cardView(systemImage: "bolt.fill", title: defineGoalVM.pace.shortLabel, legend: "Allure cible")
                        .foregroundStyle(.yellow)
                    cardView(systemImage: defineGoalVM.progression.image, title: defineGoalVM.progression.state, legend: "actuellement")
                        .foregroundStyle(defineGoalVM.progression.color)
                    cardView(systemImage: "star.fill", title: defineGoalVM.progression.label, legend: defineGoalVM.progression.feedback)
                        .foregroundStyle(.yellow)
                }
                .frame(maxWidth: .infinity)
                
                if let preset = PresetDistance.allCases.first(where: {$0.meters == defineGoalVM.distanceType.meters}), let pr = defineGoalVM.prs[preset] {
                    HStack {
                        Image(systemName: "lightbulb.max")
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(height: 60)
                            .foregroundStyle(.yellow)
                        Text("Ton record personnel sur \(defineGoalVM.distanceType.title) est de \(Duration(Int(pr.time)).longLabel)")
                            .multilineTextAlignment(.leading)
                        Spacer()
                    }
                    .padding()
                    .background {
                        RoundedRectangle(cornerRadius: 16)
                            .fill(Color.customPrimary)
                    }
                    
                    Button {
                        if !runnerProfileVM.save(Goal(type: defineGoalVM.goalType, distance: defineGoalVM.distanceType, targetTime: Int(defineGoalVM.time)), for: profiles.first) {
                            print("Fail to save goal")
                        }
                    } label: {
                        Text("Enregistrer")
                            .font(.title.bold())
                            .foregroundStyle(.white)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background {
                                RoundedRectangle(cornerRadius: 16)
                                    .fill(.teal)
                            }
                    }
                }
            }
            
        }
        .padding()
        .background(Color.background)
        .onAppear {
            if let profile = profiles.first {
                let goal = profile.goal
                defineGoalVM.prs = profile.prs
                defineGoalVM.distanceType = goal.distance
                defineGoalVM.customDistance = goal.distance.meters
                defineGoalVM.time = Double(goal.targetTime ?? 180)
            }
        }
        .onChange(of: defineGoalVM.distanceType) {
            defineGoalVM.time = Double(defineGoalVM.timeBounds.max / 2)
        }
    }
    
    @ViewBuilder
    func CustomTextField(_ title: String, systemName: String, value: Binding<Double>) -> some View {
        HStack {
            Image(systemName: systemName)
                .foregroundStyle(.teal)
            Text(title)
            Spacer()
            TextField("", value: value, format: .number)
                .multilineTextAlignment(.trailing)
        }
    }
    
    @ViewBuilder
    func cardView(systemImage: String, title: String, legend: String) -> some View {
        VStack {
            Image(systemName: systemImage)
                .font(.title2)
            Text(title)
                .font(.title3.bold())
                .foregroundStyle(.primaryText)
            Text(legend)
                .font(.caption)
                .foregroundStyle(.primaryText)
        }
        .padding()
        .frame(maxWidth: .infinity)
        .background {
            RoundedRectangle(cornerRadius: 16)
                .fill(Color.customPrimary)
        }
    }
}

#Preview {
    DefineGoalView(runnerProfileVM: .init())
}
