//
//  RouteMapView.swift
//  Striv
//
//  Created by Thibault Giraudon on 04/12/2025.
//

import SwiftUI
import CoreLocation
import MapKit

struct RouteMapView: View {
    var coordinates: [CLLocationCoordinate2D] = []
    @State private var cameraPosition: MapCameraPosition
    
    init(coordinates: [CLLocationCoordinate2D] = []) {
        self.coordinates = coordinates
        self.cameraPosition = .automatic
        if !coordinates.isEmpty {
            let region: MKCoordinateRegion = centerMap(coords: coordinates)
            self.cameraPosition = .region(region)
        }
    }
    
    var body: some View {
        Map(position: $cameraPosition) {
            if !coordinates.isEmpty {
                MapPolyline(coordinates: coordinates)
                    .stroke(.customPink, lineWidth: 4)
            }
        }
        .mapStyle(.standard(emphasis: .muted, pointsOfInterest: .excludingAll , showsTraffic: false))
    }
    
    private func centerMap(coords: [CLLocationCoordinate2D]) -> MKCoordinateRegion {
        let minLat = coords.map { $0.latitude }.min() ?? 0
        let maxLat = coords.map { $0.latitude }.max() ?? 0
        let minLong = coords.map { $0.longitude }.min() ?? 0
        let maxLong = coords.map { $0.longitude }.max() ?? 0
        
        let latitude = (minLat + maxLat) / 2
        let longitude = (minLong + maxLong) / 2
        let latDelta = max((maxLat - minLat) * 1.3, 0.005)
        let longDelta = max((maxLong - minLong) * 1.3, 0.005)
        
        return .init(center: .init(latitude: latitude, longitude: longitude),
                     span: .init(latitudeDelta: latDelta, longitudeDelta: longDelta))
    }
}

#Preview {
    RouteMapView()
}
