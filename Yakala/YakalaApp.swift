//
//  YakalaApp.swift
//  Yakala
//
//  Created by gk_vall on 24.05.2026.
//

import SwiftUI

@main
struct YakalaApp: App {
    @StateObject private var appState = AppState()
    @StateObject private var locationManager = LocationManager()

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(appState)
                .environmentObject(locationManager)
        }
    }
}
