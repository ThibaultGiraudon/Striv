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
    let count: Int
    let duration: Duration
    let elevation: Double
}

struct GlobalStats {
    let totalDistance: Double
    let totalDuration: Duration
    let totalElevation: Double
    let count: Int
}

class WorkoutsViewModel: ObservableObject {
    @Published var workouts: Workouts = [] {
        didSet {
            weeklyStats = self.computedWeeklyStats()
        }
    }
    @Published var error: AIError?
    @Published private(set) var weeklyStats: [WeeklyStat] = []
    
    var globalStats: GlobalStats {
        
        var distance: Double = 0
        var duration: Int = 0
        var elevation: Double = 0
        
        for workout in self.workouts {
            distance += (workout.distance ?? 0) / 1000
            duration += workout.duration.totalSeconds
            elevation += workout.elevation ?? 0
        }
        
        return .init(
            totalDistance: distance,
            totalDuration: .init(duration),
            totalElevation: elevation,
            count: workouts.count
        )
    }
    
    var lastFourWeeksStats: GlobalStats {
        
        var distance: Double = 0
        var duration: Int = 0
        var elevation: Double = 0
        var count: Int = 0
        
        for weekStat in self.weeklyStats.suffix(4) {
            distance += weekStat.distance
            duration += weekStat.duration.totalSeconds
            elevation += weekStat.elevation
            count += weekStat.count
        }
        
        return .init(
            totalDistance: distance,
            totalDuration: .init(duration),
            totalElevation: elevation,
            count: count
        )
    }
    
    var currentWeekStats: GlobalStats {
        .init(
            totalDistance: weeklyStats.last?.distance ?? 0,
            totalDuration: weeklyStats.last?.duration ?? .init(0),
            totalElevation: weeklyStats.last?.elevation ?? 0,
            count: weeklyStats.last?.count ?? 0
        )
    }
    
    var currentStreak: Int {
        var streak: Int = 0
        let sortedWeeks: [WeeklyStat] = weeklyStats.sorted { $0.startOfWeek > $1.startOfWeek }
        
        for week in sortedWeeks {
            if week.count > 0 {
                streak += 1
            } else {
                return streak
            }
        }
        
        return streak
    }
    
    var longestStreak: Int {
        var longestStreak: Int = 0
        var currentStreak: Int = 0
        let sortedWeeks: [WeeklyStat] = weeklyStats.sorted { $0.startOfWeek > $1.startOfWeek }
        
        for week in sortedWeeks {
            if week.count > 0 {
                currentStreak += 1
            } else {
                if currentStreak >= longestStreak {
                    longestStreak = currentStreak
                }
                currentStreak = 0
            }
        }
        
        return longestStreak > currentStreak ? longestStreak : currentStreak
    }
    
    func computedWeeklyStats() -> [WeeklyStat] {
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
            var duration: Int = 0
            var elevation: Double = 0
            
            if let workouts = grouped[startOfWeek] {
                distance = workouts.reduce(0) {
                    $0 + (($1.distance ?? 0) / 1000)
                }
                
                duration = workouts.reduce(0) {
                    $0 + $1.duration.totalSeconds
                }
                
                elevation = workouts.reduce(0) {
                    $0 + ($1.elevation ?? 0)
                }
            }
            
            
            weeksStats.append(
                .init(
                    startOfWeek: startOfWeek,
                    distance: distance,
                    count: grouped[startOfWeek]?.count ?? 0,
                    duration: .init(duration),
                    elevation: elevation
                )
            )
            
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
