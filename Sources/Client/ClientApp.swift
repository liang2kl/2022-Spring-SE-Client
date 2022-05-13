//
//  ClientApp.swift
//  Client
//
//  Created by liang2kl on 2022/4/7.
//

import SwiftUI

@main
struct ClientApp: App {
    @UIApplicationDelegateAdaptor var appDelegate: AppDelegate
    
    var body: some Scene {
        WindowGroup {
            HomeTabView()
        }
    }
}
