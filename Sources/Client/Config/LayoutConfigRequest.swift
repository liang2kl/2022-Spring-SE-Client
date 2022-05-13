//
//  LayoutConfigRequest.swift
//  Client
//
//  Created by liang2kl on 2022/4/19.
//

import Foundation
import ConfigService
import Defaults

struct LayoutConfigRequestResponse: Codable {
    struct Section: Codable {
        struct Data: Codable {
            struct Entry: Codable {
                var title: String
                var description: String
            }

            var entries: [Entry]
            var displayName: String
        }
        var name: String
        var data: Data
    }
    
    struct Layout: Codable {
        var columns: Int
        var fontScale: Double
    }
    
    var sections: [Section]
    var layout: Layout
}


struct LayoutConfigRequest: ConfigRequest {
    typealias Response = LayoutConfigRequestResponse
    
    struct Parameter: Codable {
        var userAge: Int
        var sections: [String]
    }
    
    static var secret: String {
        Defaults[.configSecret]
    }
    static var configID: String {
        Defaults[.configID]
    }
    var parameter: Parameter
}
