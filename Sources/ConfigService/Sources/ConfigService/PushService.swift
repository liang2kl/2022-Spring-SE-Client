//
//  File.swift
//  
//
//  Created by liang2kl on 2022/4/18.
//

import Foundation
import Starscream

public class PushService {
    public struct Response: Decodable {
        public var configId: String
        public var updateTime: Date
    }
    
    public init(configID: String, secret: String) throws {
        self.configID = configID
        self.secret = secret
        try self.setupConnection()
    }
    
    public init<R: ConfigRequest>(for ConfigType: R.Type) throws {
        self.configID = ConfigType.configID
        self.secret = ConfigType.secret
        try self.setupConnection()
    }
    
    private func setupConnection() throws {
        guard let baseURL = ConfigService.baseURL else {
            throw RequestError.invalidURL
        }
        let url = baseURL.appendingPathComponent("push")
            .appendingPathComponent(configID)
        
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.addValue(secret, forHTTPHeaderField: "Secret")
        
        socket = WebSocket(request: request)
        socket.delegate = self
    }
    
    public var configID: String
    public var secret: String
    public private(set) var isConnected = false
    
    var socket: WebSocket!

    public var onConnect: (() -> Void)?
    public var onDisconnect: (() -> Void)?
    public var onReceive: ((Response) -> Void)?
    public var onError: ((RequestError) -> Void)?

    public func connect() {
        guard !isConnected else { return }
        socket.connect()
    }
    
    public func disconnect() {
        guard isConnected else { return }
        socket.disconnect()
    }
}

extension PushService: WebSocketDelegate {
    public func websocketDidConnect(socket: WebSocketClient) {
        isConnected = true
        onConnect?()
    }
    
    public func websocketDidDisconnect(socket: WebSocketClient, error: Error?) {
        isConnected = false
        onDisconnect?()
        if let error = error {
            onError?(.requestError(error))
        }
    }
    
    public func websocketDidReceiveMessage(socket: WebSocketClient, text: String) {
        guard let data = text.data(using: .utf8) else {
            onError?(RequestError.decodingError(nil))
            return
        }
        
        websocketDidReceiveData(socket: socket, data: data)
    }
    
    public func websocketDidReceiveData(socket: WebSocketClient, data: Data) {
        do {
            let response = try JSONDecoder.default.decode(Response.self, from: data)
            onReceive?(response)
        } catch {
            onError?(.decodingError(error))
        }
    }
}
