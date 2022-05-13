//
//  SettingsView.swift
//  Client
//
//  Created by liang2kl on 2022/5/9.
//

import SwiftUI
import ConfigService
import Defaults

struct SettingsView: View {
    @State private var deviceID = ConfigService.deviceID ?? ""
    @Default(.configID) var configID
    @Default(.configSecret) var secret

    var body: some View {
        NavigationView {
            List {
                Section(header: Text("Configuration ID")) {
                    TextField("Config ID", text: $configID)
                }

                Section(header: Text("Secret")) {
                    TextField("Secret", text: $secret)
                }

                Section(header: Text("Mock Device ID")) {
                    TextField("Device ID", text: $deviceID)
                }
                
            }
            .navigationTitle("Settings")
        }
        .navigationViewStyle(.stack)
        .onChange(of: deviceID) {
            ConfigService.deviceID = $0
        }
        .onChange(of: configID) { _ in
            postNotification()
        }
        .onChange(of: secret) { _ in
            postNotification()
        }
    }
    
    private func postNotification() {
        // Notify view model to handle push service.
        // The publisher from `Defaults` doesn't work, so this is the workaround.
        NotificationCenter.default.post(name: .configDidChangeNotification, object: nil)
    }
}
