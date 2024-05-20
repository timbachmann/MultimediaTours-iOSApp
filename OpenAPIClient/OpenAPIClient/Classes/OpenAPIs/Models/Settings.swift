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
    public var userThumbRight: Bool
    
    public init(serverAddress: String, userThumbRight: Bool) {
        self.serverAddress = serverAddress
        self.userThumbRight = true
    }
}
