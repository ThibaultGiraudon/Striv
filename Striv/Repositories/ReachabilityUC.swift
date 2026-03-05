//
//  ReachabilityUC.swift
//  Striv
//
//  Created by Thibault Giraudon on 05/03/2026.
//


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