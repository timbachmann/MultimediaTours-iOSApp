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
    @State var userThumbLeft: Bool = true
    
    var body: some View {
        ZStack {
            List {
                Section(header: Label("Server Address", systemImage: "link.icloud")) {
                    TextField(settingsModel.serverAddress, text: $serverAddress, onCommit: {
                        settingsModel.serverAddress = serverAddress
                        settingsModel.saveSettingsToFile()
                    })
                }
                Section(header: Label("Control Center Alignment", systemImage: "hand.point.up")) {
                    Toggle(isOn: $userThumbLeft) {
                        Text("Left handed use")
                    }
                }
            }
            .onAppear(perform: {
                userThumbLeft = !settingsModel.userThumbRight
                serverAddress = settingsModel.serverAddress
            })
            .onChange(of: userThumbLeft) { value in
                settingsModel.userThumbRight = !userThumbLeft
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
