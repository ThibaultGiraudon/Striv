//
//  RunDetailView.swift
//  Striv
//
//  Created by Thibault Giraudon on 04/12/2025.
//

import SwiftUI

protocol StatDisplayable {
    var statText: String { get }
}

extension String: StatDisplayable {
    var statText: String {
        self
    }
}

extension Double: StatDisplayable {
    var statText: String {
        String(format: "%.0f", self)
    }
}

extension Int: StatDisplayable {
    var statText: String {
        String(describing: self)
    }
}

extension Date {
    var hour: Int {
        Calendar.current.component(.hour, from: self)
    }
}

struct RunDetailView: View {
    var workout: Workout
    @State private var statViewHeight = 400.0
    @ObservedObject var workoutsVM: WorkoutsViewModel
    @State private var isShowingAnalyse: Bool = false
    @State private var analyse: Analyse?
    
    var title: String {
        let hour = workout.date.hour

        switch hour {
        case 5..<11:
            return "Morning run"
        case 11..<14:
            return "Midday run"
        case 14..<18:
            return "Afternoon run"
        case 18..<22:
            return "Evening run"
        default:
            return "Night run"
        }
    }
    
    var body: some View {
        VStack {
            ZStack {
                RouteMapView(coordinates: workout.coordinates)
                    .disabled(true)
                VStack(alignment: .leading) {
                    Text(workout.date.toString(format: "EEEE,"))
                        .font(.title.bold())
                    Text(title)
                        .font(.largeTitle.bold())
                    
                    GeometryReader { geo in
                        VStack(alignment: .leading) {
                            Spacer()
                            Text("\((workout.distance ?? 0) / 1000, specifier: "%.2f")km")
                                .font(.switzer(size: 66, weight: .bold))
                                .italic()
                                .frame(height: geo.size.height * 1/8)
                                .padding(.bottom)
                            VStack {
                                RoundedRectangle(cornerRadius: 5)
                                    .frame(width: 40, height: 5)
                                    .padding(.top)
                                    .gesture(
                                        DragGesture()
                                            .onChanged({ value in
                                                let newHeight = statViewHeight - value.translation.height
                                                statViewHeight = min(max(newHeight, 100), geo.size.height)
                                            })
                                    )
                                    .onTapGesture {
                                        print("Tapped")
                                    }
                                ScrollView {
                                    statRow(systemImage: "clock", title: "Time", value: "\(workout.duration.hours):\(workout.duration.minutes):\(workout.duration.seconds)")
                                    statRow(systemImage: "figure.run", title: "Avg Pace", value: "\(workout.pace.minutes)'\(workout.pace.seconds < 10 ? "0" : "")\(workout.pace.seconds)\"")
                                    statRow(systemImage: "suit.heart", title: "Heart rate", value: workout.hr)
                                    statRow(systemImage: "flame", title: "Calories", value: workout.kcal)
                                    statRow(systemImage: "mountain.2", title: "Elevation gained", value: workout.elevation)
                                    statRow(systemImage: "powerplug.portrait", title: "Power", value: workout.power)
                                    statRow(systemImage: "figure.run", title: "Cadence", value: workout.cadence)
                                }
                            }
                            .frame(height: statViewHeight * 3/4)
                            .glassEffect(in: .rect(cornerRadius: 16.0))
                            .font(.title2)
                        }
                    }
                    
                }
                .foregroundStyle(.primaryText)
                .padding()
                AnalyseView(response: analyse, error: workoutsVM.error)
                    .offset(y: isShowingAnalyse ? 0 : -1000)
            }
        }
        .navigationTitle(workout.date.toString(format: "dd MMM. YYYY"))
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) { 
                Button("Analyse", systemImage: isShowingAnalyse ? "xmark" : "apple.intelligence") {
                    Task {
                        withAnimation {
                            isShowingAnalyse.toggle()
                        }
                        if workout.analyse.sections.isEmpty {
                            analyse = await workoutsVM.getWorkoutAnalyse(for: workout)
                        }
                        else {
                            analyse = workout.analyse
                        }
                    }
                }
            }
        }
    }
    
    @ViewBuilder
    func statRow(systemImage: String, title: String, value: StatDisplayable?) -> some View{
        if let value, value.statText != "0" {
            HStack {
                Image(systemName: systemImage)
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 20)
                Text(title)
                    .padding(.leading, 20)
                Spacer()
                Text(value.statText)
            }
            .padding(.vertical)
            .padding(.horizontal, 20)
        }
    }
}

#Preview {
    NavigationStack {
        RunDetailView(workout: Workout(date: .now, distance: 12129, duration: .init(4400), hr: 171, kcal: 949, elevation: 275, cadence: 151, power: 221, coordinates: []), workoutsVM: .init())
    }
}
