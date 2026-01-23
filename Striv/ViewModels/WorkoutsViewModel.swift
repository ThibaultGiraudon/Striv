//
//  WorkoutsViewModel.swift
//  Striv
//
//  Created by Thibault Giraudon on 02/12/2025.
//

import Foundation
import Combine
import HealthKit
import CoreLocation
import FirebaseAILogic
import Network

protocol ReachabilityUC {
    func execute() -> Bool
}

class NetworkMonitor: ReachabilityUC {
    
    private let monitor: NWPathMonitor
    private let queue: DispatchQueue
    private var isConnected = false

    init() {
        monitor = NWPathMonitor()
        queue = DispatchQueue.global(qos: .background)
        monitor.pathUpdateHandler = { [weak self] path in
            self?.isConnected = path.status == .satisfied
        }
        monitor.start(queue: self.queue)
    }
    
    func execute() -> Bool {
        isConnected
    }
}

struct WeeklyStat: Identifiable, Hashable {
    var id = UUID()
    let startOfWeek: Date
    var endOfWeek: Date {
        startOfWeek.addingTimeInterval(3600 * 24 * 6)
    }
    var label: String {
        startOfWeek.toString(format: "d MMM") + "-" + endOfWeek.toString(format: "d MMM")
    }
    let distance: Double
}

class WorkoutsViewModel: ObservableObject {
    @Published var workouts: Workouts = []
    @Published var error: AIError?
    
//    var distanceTotal: Int {
//        var total: Double = 0
//        
//        for workout in workouts {
//            total += workout.distance ?? 0
//        }
//        
//        return Int(total)
//    }
//    
//    var durationTotal: Duration {
//        var total: Int = 0
//        
//        for workout in workouts {
//            total += workout.duration.totalSeconds
//        }
//        
//        return Duration(total)
//    }
//    
//    var elevationTotal: Double {
//        var total: Double = 0
//        
//        for workout in workouts {
//            total += workout.elevation ?? 0
//        }
//        
//        return total
//    }
    
    var weeklyStats: [WeeklyStat] {
        guard let firstWeek = workouts
            .min(by: { $0.date < $1.date })?
            .date
            .firstDayOfWeek else {
            return []
        }

        var weeksStats: [WeeklyStat] = []
        
        let grouped = Dictionary(grouping: workouts) {
            $0.date.firstDayOfWeek
        }
        
        var currentWeek = Date().firstDayOfWeek
        
        while firstWeek <= currentWeek {
            let startOfWeek = currentWeek.firstDayOfWeek
            
            var distance: Double = 0
            
            if let workouts = grouped[startOfWeek] {
                distance = workouts.reduce(0) {
                    $0 + (($1.distance ?? 0) / 1000)
                }
            }
            weeksStats.append(.init(startOfWeek: startOfWeek, distance: distance))
            
            currentWeek = Calendar.current.date(byAdding: .weekOfYear, value: -1, to: currentWeek)!
        }
        
        return weeksStats.sorted(by: { $0.startOfWeek < $1.startOfWeek })
    }
    
    private let aiRepository: AIRepository = .init()
    private var isConnected: Bool = false
    private let networkMonitor = NetworkMonitor()
    
    func fetchWorkouts() async {
        do {
            let hkWorkouts = try await HealthKitHelper.shared.getWorkouts()
            
            for hkWorkout in hkWorkouts {
                do {
                    let distance = try await HealthKitHelper.shared.fetchDistance(for: hkWorkout)
                    let hr = try await HealthKitHelper.shared.fetchAverageHeartRate(for: hkWorkout)
                    let kcal = try await HealthKitHelper.shared.fetchActiveEnergy(for: hkWorkout)
                    let power = try await HealthKitHelper.shared.fetchPower(for: hkWorkout)
                    let stepCount = try await HealthKitHelper.shared.fetchCadence(for: hkWorkout)
                    let elevation = hkWorkout.metadata?["HKElevationAscended"] as? HKQuantity
                    let routes = try await HealthKitHelper.shared.fetchRoute(for: hkWorkout)
                    
                    var locations: [CLLocation] = []
                    
                    if let firstRoute = routes.first {
                        locations = try await HealthKitHelper.shared.fetchCoordinates(for: firstRoute)
                    }
                    
                    let altitudes = locations.filter { $0.verticalAccuracy > 0 }.map { $0.altitude }
                    let coordinates = locations.map { $0.coordinate }
                    
                    let duration = hkWorkout.endDate.timeIntervalSince(hkWorkout.startDate)
                    let cadence = (stepCount ?? 0) / (duration / 60)
                    
                    let workout = Workout(date: hkWorkout.startDate, distance: distance, duration: .init(Int(duration)), hr: hr, kcal: kcal, elevation: elevation?.doubleValue(for: .meter()), cadence: cadence, power: power, coordinates: coordinates, altitudes: altitudes)
                    self.workouts.append(workout)
                } catch {
                    print(error.localizedDescription)
                    continue
                }
            }
        } catch {
            print(error.localizedDescription)
        }
    }
    
    func getWorkoutAnalyse(for workout: Workout) async -> Analyse? {
        self.error = nil
        do {
            if networkMonitor.execute() {
                return try await self.aiRepository.askGemini(with: workout.analysePrompt)
            } else {
                self.error = .connection
            }
        } catch {
            if error as? GenerateContentError != nil {
                self.error = .internalAI
            } else {
                self.error = .invalid
            }
        }
        return nil
    }
}

extension WorkoutsViewModel {
    enum AIError: Error, LocalizedError, Hashable {
        case internalAI
        case invalid
        case connection
        
        var title: String {
            switch self {
            case .internalAI:
                "Service error."
            case .invalid:
                "Internal error."
            case .connection:
                "No internet connection."
            }
        }
        
        var description: String {
            switch self {
            case .internalAI:
                "The service is currently unable to process your request."
            case .invalid:
                "We failed to process your request"
            case .connection:
                "Please check your connection and try again."
            }
        }
        
        var icon: String {
            switch self {
            case .internalAI:
                "wrench.and.screwdriver"
            case .invalid:
                "externaldrive.trianglebadge.exclamationmark"
            case .connection:
                "wifi.slash"
            }
        }
    }
}
