//
//  ConfigService.swift
//
//
//  Created by liang2kl on 2022/4/18.
//

import Foundation

public struct ConfigService {
    public static var baseURL: URL?
    public static var appVersion: Int?
    public static var platform: Platform?
    public static var deviceID: String?
}

public enum Platform: String, Encodable {
    case iphone
    case ipad
    case mac
}
