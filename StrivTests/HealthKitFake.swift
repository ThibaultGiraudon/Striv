//
//  HealthKitFake.swift
//  StrivTests
//
//  Created by Thibault Giraudon on 25/04/2026.
//

import Foundation
@testable import Striv
import CoreLocation

class HealthKitFake: HealthKitHelperInterface {
    var error: Error?
    var workouts: [Workout] = []
    var ids: [UUID] = []
    var coordinates: [CLLocation] = []
    var activeEnergy: Double?
    var averageHR: Double?
    var distance: Double?
    var power: Double?
    var cadence: Double?
    var samples: [Striv.RunSample] = []
    
    func requestAuthorization() async throws {
        if let error {
            throw error
        }
    }
    
    func syncWorkouts() async throws -> ([Striv.Workout], [UUID]) {
        if let error {
            throw error
        }
        
        return (self.workouts, self.ids)
    }
    
    func fetchCoordinates(with id: UUID) async throws -> [CLLocation] {
        if let error {
            throw error
        }
        
        return self.coordinates
    }
    
    func fetchActiveEnergy(with id: UUID) async throws -> Double? {
        if let error {
            throw error
        }
        
        return self.activeEnergy
    }
    
    func fetchAverageHeartRate(with id: UUID) async throws -> Double? {
        if let error {
            throw error
        }
        
        return self.averageHR
    }
    
    func fetchDistance(with id: UUID) async throws -> Double? {
        if let error {
            throw error
        }
        
        return self.distance
    }
    
    func fetchPower(with id: UUID) async throws -> Double? {
        if let error {
            throw error
        }
        
        return self.power
    }
    
    func fetchCadence(with id: UUID) async throws -> Double? {
        if let error {
            throw error
        }
        
        return self.cadence
    }
    
    func fetchRunSamples(with id: UUID) async throws -> [Striv.RunSample] {
        if let error {
            throw error
        }
        
        return self.samples
    }
}
