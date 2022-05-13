//
//  Utilities.swift
//  
//
//  Created by liang2kl on 2022/4/18.
//

import Foundation
#if canImport(UIKit)
import UIKit
#endif

enum Utilities {
    #if os(iOS)
    static let deviceID = UIDevice.current.identifierForVendor!.uuidString
    #else
    static let deviceID = "FIXME"
    #endif
}
