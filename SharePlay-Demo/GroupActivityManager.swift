//
//  GroupActivityManager.swift
//  SharePlay-Demo
//
//  Created by Shunzhe Ma on 2021/11/10.
//

import Foundation
import Combine
import GroupActivities

@MainActor
class GroupActivityManager: ObservableObject {
    
    // Your message
    @Published var latestUUID: UUID?
    
    // SharePlay session
    @Published var groupSession: GroupSession<DemoGroupActivityType>?
    var messenger: GroupSessionMessenger?
    
    // Combine related
    var subscriptions = Set<AnyCancellable>()
    var tasks = Set<Task<Void, Never>>()
    
    func startSharing() {
        Task {
            do {
                _ = try await DemoGroupActivityType().activate()
            } catch {
                print("Failed to activate DrawTogether activity: \(error)")
            }
        }
    }
    
    func configureGroupSession(_ groupSession: GroupSession<DemoGroupActivityType>) {
        
        self.groupSession = groupSession
        let messenger = GroupSessionMessenger(session: groupSession)
        self.messenger = messenger
        
        // Handle the status of session invalidation
        groupSession.$state
            .sink { state in
                if case .invalidated = state {
                    self.groupSession = nil
                    self.reset()
                }
            }
            .store(in: &subscriptions)
        
        // Handle the case of participants' list change
        groupSession.$activeParticipants
            .sink { activeParticipants in
                print(activeParticipants)
            }
            .store(in: &subscriptions)
        
        let task = Task {
            for await (message, _) in messenger.messages(of: DemoMessage.self) {
                handle(message)
            }
        }
        tasks.insert(task)
        
        groupSession.join()
        
    }
    
    func send(_ message: DemoMessage) {
        if let messenger = messenger {
            Task {
                try? await messenger.send(message)
            }
        }
    }
    
    func handle(_ message: DemoMessage) {
        print("Received message: \(message)")
        latestUUID = message.id
    }
    
    func reset() {
        latestUUID = nil
        messenger = nil
        tasks.forEach { $0.cancel() }
        tasks = []
        subscriptions = []
        if groupSession != nil {
            groupSession?.leave()
            groupSession = nil
            self.startSharing()
        }
    }
    
}
