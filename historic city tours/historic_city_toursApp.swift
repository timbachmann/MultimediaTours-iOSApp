//
//  historic_city_toursApp.swift
//  historic city tours
//
//  Created by Tim Bachmann on 03.03.2024.
//

import SwiftUI

@main
struct historic_city_toursApp: App {
    @StateObject private var imageData = MultimediaObjectData()
    @StateObject private var locationManagerModel = LocationManagerModel()
    @StateObject private var settingsModel = SettingsModel()
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(imageData)
                .environmentObject(locationManagerModel)
                .environmentObject(settingsModel)
        }
    }
}
