//
//  WorkoutsVMTests.swift
//  StrivTests
//
//  Created by Thibault Giraudon on 25/04/2026.
//

import XCTest
import SwiftData
@testable import Striv

func makeContainer() throws -> ModelContainer {
    let schema = Schema([Workout.self,
                         Duration.self,
                         Coordinate.self,
                         RunnerProfile.self,
                         RunSampleEntity.self])
    let config = ModelConfiguration(isStoredInMemoryOnly: true)
    return try ModelContainer(for: schema, configurations: [config])

}

extension Workout {
    static func mock() -> Workout {
        return Workout(id: UUID(), date: .now, duration: Duration(3600))
    }
}

extension RunSampleEntity {
    static func mock(distance: Double = 10_000, time: Double = 3_600) -> [RunSampleEntity] {
        
        var samples: [RunSampleEntity] = []
        
        let totalDistance: Double = distance
        let totalTime: Double = time
        
        let distanceStep = totalDistance / Double(150)
        let timeStep = totalTime / Double(150)
        
        for i in 0..<150 {
            let distance = Double(i) * distanceStep
            let time = Double(i) * timeStep
            
            samples.append(
                RunSampleEntity(
                    distance: distance,
                    time: time
                )
            )
        }
        
        samples.removeLast()
        samples.append(RunSampleEntity(distance: distance, time: time))
        
        return samples
    }
}

@MainActor
final class WorkoutsVMTests: XCTestCase {
    var container: ModelContainer!
    var context: ModelContext!
    var errorPresenter: ErrorPresenter!
    var healthKitFake: HealthKitFake!
    var vm: WorkoutsViewModel!

    override func setUp() async throws {
        container = try makeContainer()
        context = ModelContext(container)
        errorPresenter = ErrorPresenter()
        let runnerProfileVM = RunnerProfileViewModel(errorPresenter: errorPresenter)

        healthKitFake = HealthKitFake()

        vm = WorkoutsViewModel(
            healthKitHelper: healthKitFake,
            errorPresenter: errorPresenter
        )

        vm.setContext(context: context)
        vm.setRunnerProfileVM(runnerProfileVM)
    }

    func test_fetchWorkoutsSummary_insertsNewWorkouts() async throws {
        // GIVEN
        let workout = Workout.mock() // à créer

        healthKitFake.workouts = [workout]
        
        // WHEN
        await vm.fetchWorkoutsSummary()

        // THEN
        let fetch = FetchDescriptor<Workout>()
        let results = try context.fetch(fetch)

        XCTAssertEqual(results.count, 1)
        XCTAssertEqual(results.first?.id, workout.id)
    }
    
    func test_fetchWorkoutsSummary_throwsError() async throws {
        healthKitFake.error = HealthKitError.notAuthorized
        
        await vm.fetchWorkoutsSummary()
        
        XCTAssertEqual(errorPresenter.error, AppError.database(.saving))
    }
    
    func test_fetchWorkoutsDetailIfNeeded_addMetrics() async throws {
        healthKitFake.activeEnergy = 450
        healthKitFake.averageHR = 155
        healthKitFake.cadence = 167 * 60
        healthKitFake.power = 200
        
        let workout = await vm.fetchWorkoutDetailIfNeeded(for: Workout.mock())
        
        XCTAssertEqual(workout.kcal, 450)
        XCTAssertEqual(workout.hr, 155)
        XCTAssertEqual(workout.cadence, 167)
        XCTAssertEqual(workout.power, 200)
    }
    
    func test_bestTimes_PRonFiveK() async throws {
        let bestTimes = vm.bestTimes(in: RunSampleEntity.mock())
        
        XCTAssertEqual(bestTimes[PresetDistance.fiveK], 1800)
    }
    
    func test_bestTimes_PRonTenK() async throws {
        let bestTimes = vm.bestTimes(in: RunSampleEntity.mock())
        
        XCTAssertEqual(bestTimes[PresetDistance.fiveK], 1800)
        XCTAssertEqual(bestTimes[PresetDistance.tenK], 3600)
    }
}
