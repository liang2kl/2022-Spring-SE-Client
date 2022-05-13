//
//  RequestError.swift
//  
//
//  Created by liang2kl on 2022/4/18.
//

import Foundation

public enum RequestError: Error {
    case invalidURL
    case invalidAppVersion
    case invalidPlatform
    case decodingError(Error?)
    case requestError(Error)
    case unacceptableStatusCode(String)
    
    public var description: String {
        switch self {
        case .decodingError(let error):
            let error = error ?? self
            return "\(error)"
        case .requestError(let error):
            return "\(error)"
        case .unacceptableStatusCode(let description):
            return description
        default:
            return "\(self)"
        }
    }
}
