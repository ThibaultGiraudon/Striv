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
    @StateObject var workoutsVM: WorkoutsViewModel = .init()

    var body: some View {
        NavigationStack {
            Button("Tap") {
                Task {
                    await workoutsVM.fetchWorkouts()
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
