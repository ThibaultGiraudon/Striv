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
    @State private var goalType: GoalType = .time
    @State private var distanceType: DistanceType = .preset(.marathon)
    @State private var customDistance: Double = 0.0
    @State private var time: Double = 180
    var timeBounds: (min: Int, max: Int) {
        let km = distanceType.meters / 1000
        let minPace: Double = 150 + km
        let maxPace: Double = 600
        
        return (Int((minPace * km))/60, Int((maxPace * km))/60)
    }
    var formatTime: String {
        let h = Int(time) / 60
        let m = Int(time) % 60
        
        if h > 0 {
            return "\(h)h\(m<10 ? "0" : "")\(m)"
        } else {
            return "\(m) min"
        }
    }
    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                Text("Définir objectif")
                    .font(.title.bold())
                Picker("Type d'objectif", selection: $goalType) {
                    ForEach(GoalType.allCases, id: \.self) { goalType in
                        Text(goalType.rawValue)
                    }
                }
                .pickerStyle(.segmented)
                
                Picker("", selection: $distanceType) {
                    ForEach(PresetDistance.allCases, id: \.self) { preset in
                        Text(preset.title).tag(DistanceType.preset(preset))
                    }
                }
                .pickerStyle(.segmented)
                
                Button {
                    distanceType = .custom(customDistance)
                } label: {
                    Text("Distance personnalisée")
                        .foregroundStyle(.white)
                }
                .frame(maxWidth: .infinity)
                .padding(5)
                .background {
                    Capsule()
                        .fill(
                            distanceType.title == "Distance personnalisée" ? .tertiary : .quinary
                        )
                }
                
                if distanceType.title == "Distance personnalisée" {
                    CustomTextField("Distance en m", systemName: "flag.checkered", value: $customDistance)
                        .onSubmit {
                            distanceType = .custom(customDistance)
                        }
                }
                
                Slider(value: $time, in: Double(timeBounds.min)...Double(timeBounds.max))
                Text(formatTime)
            }
            
        }
        .padding()
        .background(Color.background)
        .overlay(alignment: .bottom) {
            Button {
                if !runnerProfileVM.save(Goal(type: goalType, distance: distanceType, targetTime: Int(time)), for: profiles.first) {
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
                    .padding()
            }
        }
        .onAppear {
            print(profiles)
            if let profile = profiles.first {
                let goal = profile.goal
                self.distanceType = goal.distance
                self.customDistance = goal.distance.meters
                self.time = Double(goal.targetTime ?? 180)
            }
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
}

#Preview {
    DefineGoalView(runnerProfileVM: .init())
}
