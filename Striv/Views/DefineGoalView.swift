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

    var body: some View {
        ScrollView {
            VStack(alignment: .leading) {
                Text("Définir objectif")
                    .font(.title.bold())
                Text("Choisi ton objectif de course.")
                
                SegmentedPicker(items: GoalType.allCases, title: { $0.rawValue }, selection: $goalType, size: 10)
                    .font(.title2)
                    .padding(.vertical)
                
                SegmentedPicker(items: DistanceType.allCases, title: { $0.title }, selection: $distanceType, size: 10)
                    .padding(.bottom)
                
                Button {
                    distanceType = .custom(customDistance)
                } label: {
                    Text("Distance personnalisée")
                        .foregroundStyle(.white)
                }
                .frame(maxWidth: .infinity)
                .padding(10)
                .background {
                    Capsule()
                        .fill(
                            distanceType.title == "Distance personnalisée" ? .teal : .customPrimary
                        )
                }
                
                if distanceType.title == "Distance personnalisée" {
                    CustomTextField("Distance en m", systemName: "flag.checkered", value: $customDistance)
                        .onSubmit {
                            distanceType = .custom(customDistance)
                        }
                }
                
                VStack(alignment: .center) {
                    Text(formatTime)
                        .font(.system(size: 50).bold())
                    Text("Objectif pour \(Int(distanceType.meters / 1000)) km")
                    Slider(value: $time, in: Double(timeBounds.min)...Double(timeBounds.max))
                }
                .frame(maxWidth: .infinity, alignment: .center)
                .padding()
                .background {
                    RoundedRectangle(cornerRadius: 16)
                        .foregroundStyle(Color.customPrimary)
                }
                HStack {
                    cardView(systemImage: "bolt.fill", title: pace.shortLabel, legend: "Allure cible")
                        .foregroundStyle(.yellow)
                    cardView(systemImage: progression.image, title: progression.state, legend: "actuellement")
                        .foregroundStyle(progression.color)
                    cardView(systemImage: "star.fill", title: progression.label, legend: progression.feedback)
                        .foregroundStyle(.yellow)
                }
                .frame(maxWidth: .infinity)
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
            if let profile = profiles.first {
                let goal = profile.goal
                self.distanceType = goal.distance
                self.customDistance = goal.distance.meters
                self.time = Double(goal.targetTime ?? 180)
            }
        }
        .onChange(of: distanceType) {
            self.time = Double(self.timeBounds.max / 2)
        }
    }
    
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
    
    var pace: Workout.Pace {
        return Workout.Pace(pace: time / (distanceType.meters / 1000))
    }
    
    var progression: (label: String, feedback: String, state: String, color: Color, image: String) {
        guard let profile = profiles.first else { return ("-", "Non defini", "-", .gray, "minus.circle") }
        
        guard let preset = PresetDistance.allCases.first(where: {$0.meters == distanceType.meters}) else {
            return ("-", "Non defini", "-", .gray, "minus.circle")
        }
        
        guard let pr = profile.prs[preset] else { return ("-", "Non defini", "-", .gray, "minus.circle") }
                
        let progression = ((pr.time - (time * 60)) / pr.time) * 100
        let label = String(format: "%@%.0f%%", progression >= 0 ? "+" : "", progression)
        
        var feedback: String = ""
        var state: String = ""
        var color: Color = .green
        var image: String = "minus.circle"
        
        switch progression {
        case ...0:
            feedback = "Défi atteint"
            state = "Validé"
            color = .green
            image = "checkmark.circle"
        case 0..<10:
            feedback = "Défi atteignable"
            state = "Rapidement"
            color = .green
            image = "checkmark.circle"
        case 10..<20:
            feedback = "Défi modéré"
            state = "Réaliste"
            color = .yellow
            image = "checkmark.circle"
        case 20..<30:
            feedback = "Défi ambitieux"
            state = "Challengeant"
            color = .orange
            image = "minus.circle"
        default:
            feedback = "Défi exigeant"
            state = "Difficile"
            color = .red
            image = "xmark.circle"
        }
        
        return (label, feedback, state, color, image)
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
