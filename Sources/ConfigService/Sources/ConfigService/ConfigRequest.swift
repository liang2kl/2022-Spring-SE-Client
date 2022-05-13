//
//  ConfigRequest.swift
//  
//
//  Created by liang2kl on 2022/4/18.
//

import Foundation
import Alamofire

public protocol ConfigRequest {
    associatedtype Parameter: Encodable
    associatedtype Response: Decodable
    var parameter: Parameter { get }
    static var secret: String { get }
    static var configID: String { get }
}

public extension ConfigRequest {
    func fetch(cached: Bool = true, completion: @escaping (Result<Response, RequestError>) -> Void) throws {
        let url = try url()
        AF.request(
            url,
            method: .post,
            parameters: try requestBody(),
            encoder: JSONParameterEncoder.json(encoder: .default)
        )
        .responseDecodable(of: ConfigRequestResponse<Response>.self, decoder: JSONDecoder.default) { response in
            switch response.result {
            case .success(let value):
                do {
                    if value.data != nil {
                        let response = try value.decode()
                        completion(.success(response))
                    } else {
                        completion(.failure(.unacceptableStatusCode(value.message)))
                    }
                } catch {
                    completion(.failure(.decodingError(error)))
                }
            case .failure(let error):
                if let value = response.value {
                    // FIXME: Error
                    completion(.failure(.unacceptableStatusCode(value.message)))
                } else {
                    completion(.failure(.requestError(error)))
                }
            }
        }
    }
}

struct ConfigRequestBody<P: Encodable>: Encodable {
    struct Metadata: Encodable {
        var version: Int
        var platform: Platform
        var deviceID: String
    }
    var meta: Metadata
    var cached: Bool
    var params: P
}

struct ConfigRequestResponse<R: Decodable>: Decodable {
    struct Data: Decodable {
        var result: String
        var codeId: String
    }
    var message: String
    var data: Data?
    
    func decode(with decoder: JSONDecoder = .default) throws -> R {
        guard let data = self.data!.result.data(using: .utf8) else {
            throw RequestError.decodingError(nil)
        }
        return try JSONDecoder.default.decode(R.self, from: data)
    }
}

extension ConfigRequest {
    func url() throws -> URL {
        guard let baseURL = ConfigService.baseURL else {
            throw RequestError.invalidURL
        }

        return baseURL
            .appendingPathComponent("config")
            .appendingPathComponent(Self.configID)
    }
    
    func requestBody() throws -> ConfigRequestBody<Parameter> {
        guard let appVersion = ConfigService.appVersion else {
            throw RequestError.invalidAppVersion
        }
        
        guard let platform = ConfigService.platform else {
            throw RequestError.invalidPlatform
        }
        
        let deviceID = ConfigService.deviceID ?? Utilities.deviceID
        
        return .init(meta: .init(version: appVersion, platform: platform, deviceID: deviceID), cached: false, params: parameter)
    }
}
