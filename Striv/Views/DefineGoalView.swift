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
        ScrollView(showsIndicators: false) {
            VStack(alignment: .leading) {
                Text("Définir objectif")
                    .font(.title.bold())
                Text("Choisi ton objectif de course.")
                
                SegmentedPicker(items: DistanceType.allCases, title: { $0.title }, selection: $defineGoalVM.distanceType, size: 10)
                
                Button {
                    defineGoalVM.distanceType = .custom(defineGoalVM.customDistance)
                } label: {
                    Text("Distance personnalisée")
                        .foregroundStyle(Color.primaryText)
                }
                .frame(maxWidth: .infinity)
                .padding(10)
                .contentShape(Capsule())
                .background {
                    Capsule()
                        .fill(
                            defineGoalVM.distanceType.title == "Distance personnalisée" ? .customPink : .customPrimary
                        )
                }
                .padding(.bottom)
                .accessibilityElement(children: .ignore)
                .accessibilityLabel("Distance personnalisée")
                .accessibilityHint("Double tap pour rentrer une distance personnalisée")
                
                if defineGoalVM.distanceType.title == "Distance personnalisée" {
                    CustomTextField("Distance en m", systemName: "flag.checkered", value: $defineGoalVM.customDistance)
                        .onSubmit {
                            defineGoalVM.distanceType = .custom(defineGoalVM.customDistance)
                        }
                        .accessibilityElement(children: .ignore)
                        .accessibilityLabel("Champs de texte")
                        .accessibilityHint("Double tap pour renseigner votre objectif")
                }
                
                VStack(alignment: .center) {
                    Text(defineGoalVM.formatTime)
                        .font(.system(size: 50).bold())
                        .accessibilityElement(children: .ignore)
                    Text("Objectif pour \(Int(defineGoalVM.distanceType.meters / 1000)) km")
                        .accessibilityElement(children: .ignore)
                        .accessibilityLabel("Objectif pour \(Int(defineGoalVM.distanceType.meters / 1000)) km : \(defineGoalVM.formatTime)")
                    Slider(value: $defineGoalVM.time, in: Double(defineGoalVM.timeBounds.min)...Double(defineGoalVM.timeBounds.max))
                        .accessibilityElement(children: .ignore)
                        .accessibilityLabel("Élément ajustable pour définir votre objectif de temps")
                        .accessibilityValue("\(defineGoalVM.formatTime)")
                }
                .frame(maxWidth: .infinity, alignment: .center)
                .padding()
                .background {
                    RoundedRectangle(cornerRadius: 16)
                        .foregroundStyle(Color.customPrimary)
                }
                HStack {
                    cardView(systemImage: "figure.run", title: defineGoalVM.pace.shortLabel, legend: "Allure cible")
                        .foregroundStyle(.teal)
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
                    .accessibilityElement(children: .ignore)
                    .accessibilityLabel("Ton record personnel sur \(defineGoalVM.distanceType.title) est de \(Duration(Int(pr.time)).voiceOverLabel)")
                }
                    
                Spacer()
                
                Button {
                    if !runnerProfileVM.save(Goal(type: defineGoalVM.goalType, distance: defineGoalVM.distanceType, targetTime: Int(defineGoalVM.time)), for: profiles.first) {

                    }
                } label: {
                    Text("Enregistrer")
                        .font(.title.bold())
                        .foregroundStyle(.white)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background {
                            RoundedRectangle(cornerRadius: 16)
                                .fill(.customPink)
                        }
                }
                .accessibilityElement(children: .ignore)
                .accessibilityLabel("Enregistrer bouton")
                .accessibilityHint("Double tap pour enregistrer l'objectif")
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
                .foregroundStyle(.customPink)
            Text(title)
            Spacer()
            TextField("", value: value, format: .number)
                .multilineTextAlignment(.trailing)
        }
    }
    
    @ViewBuilder
    func cardView(systemImage: String, title: String, legend: String) -> some View {
        VStack(spacing: 6) {
            Image(systemName: systemImage)
                .font(.title2)

            Text(title)
                .font(.title3.bold())
                .foregroundStyle(.primaryText)
                .lineLimit(1)
                .minimumScaleFactor(0.6)
                .frame(height: 28)

            Text(legend)
                .font(.caption)
                .foregroundStyle(.primaryText)
                .frame(height: 16)
        }
        .padding()
        .frame(maxWidth: .infinity)
        .background {
            RoundedRectangle(cornerRadius: 16)
                .fill(Color.customPrimary)
        }
        .accessibilityElement(children: .ignore)
        .accessibilityLabel("\(legend): \(title)")
    }
}

#Preview {
    @Previewable @StateObject var errorPresenter = ErrorPresenter()
    DefineGoalView(runnerProfileVM: .init(errorPresenter: errorPresenter))
}
