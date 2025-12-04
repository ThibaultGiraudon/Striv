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
    @StateObject var workoutsVM: WorkoutsViewModel = .init()

    var body: some View {
        NavigationStack {
            VStack {
                RunsListView(workoutsVM: workoutsVM)
            }
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Download", systemImage: "arrow.down.circle") {
                        Task {
                            await workoutsVM.fetchWorkouts()
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
