//
//  ContentView.swift
//  Striv
//
//  Created by Thibault Giraudon on 02/12/2025.
//

import SwiftUI
import SwiftData
import HealthKit

struct ContentView: View {
    @Environment(\.modelContext) private var modelContext
    @Query private var items: [Item]
    private var healthStore: HealthKitHelper = .shared

    var body: some View {
        NavigationStack {
            Button("Tap") {
                Task {
                    do {
                        let workouts = try await healthStore.getWorkouts()
                        
                        for workout in workouts {
                            do {
                                let distance = try await healthStore.fetchDistance(for: workout)
                                let hr = try await healthStore.fetchAverageHeartRate(for: workout)
                                let kcal = try await healthStore.fetchActiveEnergy(for: workout)

                                print("\(workout.startDate): \((distance ?? 0)/1000)km, \(hr ?? 0)bpm, \(kcal ?? 0)kcal")
                            } catch {
                                print(error.localizedDescription)
                                continue
                            }
                            
                        }
                    }
                }
            }
        }
    }

    private func addItem() {
        withAnimation {
            let newItem = Item(timestamp: Date())
            modelContext.insert(newItem)
        }
    }

    private func deleteItems(offsets: IndexSet) {
        withAnimation {
            for index in offsets {
                modelContext.delete(items[index])
            }
        }
    }
}

#Preview {
    ContentView()
        .modelContainer(for: Item.self, inMemory: true)
}
