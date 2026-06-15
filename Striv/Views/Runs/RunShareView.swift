//
//  RunShareView.swift
//  Striv
//
//  Created by Thibault Giraudon on 15/06/2026.
//

import SwiftUI
import MapKit
import CoreLocation

struct RunMapShareView: View {
    var workout: Workout
    @Binding var color: Color

    var body: some View {
        RoutePathView(coordinates: workout.coordinates2d, color: $color)
            .padding(20)
            .background(Color.clear)
    }
}

struct RoutePathView: View {
    let coordinates: [CLLocationCoordinate2D]
    @Binding var color: Color

    var body: some View {
        GeometryReader { geometry in

            let result = makePoints(in: geometry.size)

            Path { path in
                guard let first = result.points.first else { return }

                path.move(to: first)

                for point in result.points.dropFirst() {
                    path.addLine(to: point)
                }
            }
            .stroke(
                color,
                style: StrokeStyle(
                    lineWidth: 4,
                    lineCap: .round,
                    lineJoin: .round
                )
            )
        }
    }
}

extension RoutePathView {

    struct LayoutResult {
        let points: [CGPoint]
    }

    func makePoints(in size: CGSize) -> LayoutResult {

        guard coordinates.count > 1 else {
            return LayoutResult(points: [])
        }

        let lats = coordinates.map(\.latitude)
        let lons = coordinates.map(\.longitude)

        let minLat = lats.min()!
        let maxLat = lats.max()!
        let minLon = lons.min()!
        let maxLon = lons.max()!

        let latRange = max(maxLat - minLat, 0.000001)
        let lonRange = max(maxLon - minLon, 0.000001)

        // 1. normalisation 0...1
        let normalized: [CGPoint] = coordinates.map { c in
            CGPoint(
                x: (c.longitude - minLon) / lonRange,
                y: (c.latitude - minLat) / latRange
            )
        }

        // 2. inverse Y (car lat augmente vers le nord mais écran vers le bas)
        let flipped = normalized.map { p in
            CGPoint(x: p.x, y: 1 - p.y)
        }

        // 3. scale uniforme (IMPORTANT)
        let scale = min(size.width, size.height)

        let scaled = flipped.map { p in
            CGPoint(
                x: p.x * scale,
                y: p.y * scale
            )
        }

        // 4. centrage
        let contentWidth = (lonRange >= latRange)
            ? size.width
            : scale

        let contentHeight = (latRange > lonRange)
            ? size.height
            : scale

        let offsetX = (size.width - contentWidth) / 2
        let offsetY = (size.height - contentHeight) / 2

        let finalPoints = scaled.map { p in
            CGPoint(
                x: p.x + offsetX,
                y: p.y + offsetY
            )
        }

        return LayoutResult(points: finalPoints)
    }
}

struct RunStatsShareView: View {
    var workout: Workout
    @Binding var color: Color

    var body: some View {
        VStack {
            if let distance = workout.distance {
                Text("Distance")

                Text((distance / 1000).roundedText(to: 2))
                    .font(.title)

                Text("Allure")

                Text(workout.pace.label)
                    .font(.title)

                Text("Temps")

                Text(workout.duration.label)
                    .font(.title)
            }
        }
        .foregroundStyle(color)
        .bold()
        .background(Color.clear)
    }
}

struct RunMapAndStatShareView: View {
    var workout: Workout
    @Binding var color: Color

    var body: some View {
        VStack {
            RunMapShareView(workout: workout, color: $color)
            RunStatsShareView(workout: workout, color: $color)
        }
        .background(Color.clear)
    }
}

#Preview {
    RunMapShareView(workout: .init(id: UUID(), date: .now, duration: .init(3600)), color: .constant(Color.customPink))
}
