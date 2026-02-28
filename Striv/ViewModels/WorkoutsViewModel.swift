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
    
    func fetchWorkoutsSummary() async {
        do {
            let hkWorkouts = try await HealthKitHelper.shared.getWorkouts()
            
            var newWorkouts: [Workout] = []
            
            try await withThrowingTaskGroup(of: Workout?.self) { group in
                
                for hkWorkout in hkWorkouts {
                    group.addTask {
                        do {
                            async let distance = HealthKitHelper.shared.fetchDistance(for: hkWorkout)
                            
                            let duration = hkWorkout.endDate.timeIntervalSince(hkWorkout.startDate)
                            
                            return await Workout(
                                id: hkWorkout.uuid,
                                date: hkWorkout.startDate,
                                distance: try await distance,
                                duration: .init(Int(duration)),
                                elevation: (hkWorkout.metadata?["HKElevationAscended"] as? HKQuantity?)??.doubleValue(for: .meter())
                            )
                            
                        } catch {
                            return nil
                        }
                    }
                }
                
                for try await workout in group {
                    if let workout {
                        newWorkouts.append(workout)
                    }
                }
            }
            
            await MainActor.run {
                self.workouts = newWorkouts.sorted(by: {$0.date > $1.date})
            }
            
        } catch {
            print(error.localizedDescription)
        }
    }
    
    func fetchWorkoutDetail(for workout: Workout) async -> Workout {
        guard let index = self.workouts.firstIndex(where: {$0.id == workout.id}) else {
            return workout
        }
        
        var newWorkout = workout
        
        do {
            async let hr = HealthKitHelper.shared.fetchAverageHeartRate(with: workout.id)
            async let kcal = HealthKitHelper.shared.fetchActiveEnergy(with: workout.id)
            async let power = HealthKitHelper.shared.fetchPower(with: workout.id)
            async let stepCount = HealthKitHelper.shared.fetchCadence(with: workout.id)
            async let routes = HealthKitHelper.shared.fetchRoute(with: workout.id)
            
            let resolvedRoutes = try await routes
            
            var locations: [CLLocation] = []
            if let firstRoute = resolvedRoutes.first {
                locations = try await HealthKitHelper.shared.fetchCoordinates(for: firstRoute)
            }
            
            let minutes = max(Double(newWorkout.duration.totalSeconds) / 60, 1)
            let cadence = (try await stepCount ?? 0) / minutes
            
            newWorkout.hr = try await hr
            newWorkout.kcal = try await kcal
            newWorkout.power = try await power
            newWorkout.cadence = cadence
            newWorkout.coordinates = locations.map { $0.coordinate }
            newWorkout.altitudes = locations.map { $0.altitude }
            
            self.workouts[index] = newWorkout
            return newWorkout
        } catch {
            print(error.localizedDescription)
        }
        return workout
    }
    
    func fetchWorkoutDetailIfNeeded(for workout: Workout) async -> Workout {
        guard let index = self.workouts.firstIndex(where: { $0.id == workout.id }) else {
            return workout
        }

        if workouts[index].hr != nil {
            return workouts[index]
        }

        return await fetchWorkoutDetail(for: workout)
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
