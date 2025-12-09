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
                                .frame(height: 100)
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
                                    statRow(systemImage: "figure.run", title: "Avg Pace", value: "\(workout.pace.minutes)'\(workout.pace.seconds)\"")
                                    statRow(systemImage: "flame", title: "Calories", value: workout.kcal)
                                    statRow(systemImage: "mountain.2", title: "Elevation gained", value: workout.elevation)
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
            }
        }
        .navigationTitle(workout.date.toString(format: "dd MMM. YYYY"))
        .navigationBarTitleDisplayMode(.inline)
    }
    
    @ViewBuilder
    func statRow(systemImage: String, title: String, value: StatDisplayable?) -> some View{
        if let value {
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
        RunDetailView(workout: Workout(date: .now, distance: 12129, duration: .init(4333), hr: 171, kcal: 949, elevation: 275, coordinates: []))
    }
}
