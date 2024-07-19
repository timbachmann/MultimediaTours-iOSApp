//
//  Settings.swift
//  AR-Explorer
//
//  Created by Tim Bachmann on 06.05.24.
//

import Foundation
#if canImport(AnyCodable)
import AnyCodable
#endif


public struct Settings: Codable, JSONEncodable, Hashable {
    
    public var serverAddress: String
    public var debugMode: Bool
    
    public init(serverAddress: String, debugMode: Bool) {
        self.serverAddress = serverAddress
        self.debugMode = false
    }
}
