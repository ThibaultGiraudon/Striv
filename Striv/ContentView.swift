//
//  ContentView.swift
//  Striv
//
//  Created by Thibault Giraudon on 02/12/2025.
//

import SwiftUI
import SwiftData

struct ContentView: View {
    @Environment(\.modelContext) private var modelContext
    @Query private var items: [Item]
    private var healthStore: HealthKitHelper = .shared

    var body: some View {
        NavigationStack {
            Button("Tap") {
                healthStore.getWorkouts() { result in
                    switch result {
                    case .success(let workouts):
                        print(workouts)
                        print(workouts.count)
                    case .failure(let error):
                        print(error.localizedDescription)
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
