//
//  ContentView.swift
//  SharePlay-Demo
//
//  Created by Shunzhe Ma on 2021/11/10.
//

import SwiftUI

struct ContentView: View {
    
    @StateObject var manager = GroupActivityManager()
    
    var body: some View {
        
        VStack {
            Button("Start sharing") {
                manager.startSharing()
            }
            Text(manager.latestUUID?.uuidString ?? "")
                .padding()
            Button("Send message") {
                manager.send(DemoMessage(id: UUID()))
            }
        }
            .task {
                for await session in DemoGroupActivityType.sessions() {
                    manager.configureGroupSession(session)
                }
            }
        
    }
    
}
