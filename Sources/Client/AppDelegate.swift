//
//  AppDelegate.swift
//  Client
//
//  Created by liang2kl on 2022/4/19.
//

import UIKit
import ConfigService

class AppDelegate: NSObject, UIApplicationDelegate {
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
        // Setup config service
        ConfigService.baseURL = URL(string: "https://proxy-centereddiv.app.secoder.net")
        ConfigService.platform = .iphone
        ConfigService.appVersion = 1 // FIXME
        ConfigService.deviceID = "1" // For demonstration purpose
        
        return true
    }
}
