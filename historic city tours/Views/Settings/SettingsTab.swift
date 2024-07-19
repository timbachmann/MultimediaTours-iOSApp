//
//  Settings.swift
//  CapVis-AR
//
//  Created by Tim Bachmann on 20.04.22.
//

import SwiftUI
import OpenAPIClient

/**
 
 */
struct SettingsTab: View {
    
    @EnvironmentObject var settingsModel: SettingsModel
    @State var serverAddress: String = ""
    @State var debugMode: Bool = false
    
    var body: some View {
        ZStack {
            List {
                Section(header: Label("Server Address", systemImage: "icloud")) {
                    HStack {
                        Image(systemName: "link.icloud")
                        TextField(settingsModel.serverAddress, text: $serverAddress, onCommit: {
                            settingsModel.serverAddress = serverAddress
                            settingsModel.saveSettingsToFile()
                        })
                    }
                }
                Section(header: Label("AR", systemImage: "arkit")) {
                    Toggle(isOn: $debugMode) {
                        Label("Debug Mode", systemImage: "exclamationmark.bubble")
                    }
                }
            }
            .onAppear(perform: {
                debugMode = settingsModel.debugMode
                serverAddress = settingsModel.serverAddress
            })
            .onChange(of: debugMode) { value in
                settingsModel.debugMode = debugMode
                settingsModel.saveSettingsToFile()
            }
        }
        .navigationTitle("Settings")
    }
}

struct SettingsView_Previews: PreviewProvider {
    static var previews: some View {
        SettingsTab()
    }
}
