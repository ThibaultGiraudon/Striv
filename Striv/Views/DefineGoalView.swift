//
//  DefineGoalView.swift
//  Striv
//
//  Created by Thibault Giraudon on 10/04/2026.
//

import SwiftUI
import SwiftData

struct DefineGoalView: View {
    @Environment(\.dismiss) private var dismiss
    
    let goal: Goal?
    let distance: PresetDistance
    @ObservedObject var runnerProfileVM: RunnerProfileViewModel
    @ObservedObject var goalsVM: GoalsViewModel
    
    @Query private var profiles: [RunnerProfile]
    @StateObject private var defineGoalVM = DefineGoalViewModel()
    
    var body: some View {
        VStack(alignment: .leading) {
            Text("Définir objectif")
                .font(.title.bold())
            Text("Choisi ton objectif de course.")
            
            
            VStack(alignment: .center) {
                Spacer()
                Text(defineGoalVM.formatTime)
                    .font(.system(size: 50).bold())
                    .accessibilityElement(children: .ignore)
                Text("Objectif pour \(Int(defineGoalVM.distanceType.meters / 1000)) km")
                    .accessibilityElement(children: .ignore)
                    .accessibilityLabel("Objectif pour \(Int(defineGoalVM.distanceType.meters / 1000)) km : \(defineGoalVM.formatTime)")
                Spacer()
                Slider(value: $defineGoalVM.time, in: Double(defineGoalVM.timeBounds.min)...Double(defineGoalVM.timeBounds.max), step: 1.0)
                    .accessibilityElement(children: .ignore)
                    .accessibilityLabel("Élément ajustable pour définir votre objectif de temps")
                    .accessibilityValue("\(defineGoalVM.formatTime)")
                    .transaction {
                        $0.animation = nil
                    }
            }
            .frame(maxWidth: .infinity, alignment: .center)
            .cardStyle()
            
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
                .cardStyle()
                .accessibilityElement(children: .ignore)
                .accessibilityLabel("Ton record personnel sur \(defineGoalVM.distanceType.title) est de \(Duration(Int(pr.time)).voiceOverLabel)")
            }
                
            Spacer()
            
            Toggle("Définir comme objectif principal", isOn: $defineGoalVM.isMain)
                .tint(.customPink)
                .padding(.vertical)
                .onChange(of: defineGoalVM.isMain) { oldValue, newValue in
                    goalsVM.setMainGoal(for: .init(distance: defineGoalVM.distanceType, time: defineGoalVM.time, isMain: defineGoalVM.isMain))
                }
            
            Button {
                Task {
                    await goalsVM.saveGoal(.init(distance: defineGoalVM.distanceType, time: defineGoalVM.time, isMain: defineGoalVM.isMain))
                    dismiss()
                }
            } label: {
                Text("Enregistrer")
                    .font(.title.bold())
                    .foregroundStyle(.white)
                    .frame(maxWidth: .infinity)
                    .cardStyle(.customPink)
            }
            .accessibilityElement(children: .ignore)
            .accessibilityLabel("Enregistrer bouton")
            .accessibilityHint("Double tap pour enregistrer l'objectif")
        }
        .padding()
        .background(Color.background)
        .onAppear {
            if let profile = profiles.first {
                defineGoalVM.prs = profile.prs
                defineGoalVM.distanceType = distance
                defineGoalVM.customDistance = distance.meters
                defineGoalVM.time = Double(goal?.time ?? 0)
                defineGoalVM.isMain = goal?.isMain ?? false
            }
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
    DefineGoalView(
        goal: .init(distance: .marathon, time: 150*60, isMain: false),
        distance: .marathon,
        runnerProfileVM: .init(errorPresenter: errorPresenter),
        goalsVM: .init(errorPresenter: errorPresenter))
}
