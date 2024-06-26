//
// GenerateRequest.swift
//
// Generated by openapi-generator
// https://openapi-generator.tech
//

import Foundation
#if canImport(AnyCodable)
import AnyCodable
#endif

public struct GenerateRequest: Codable, JSONEncodable, Hashable {

    public var searchQuery: String

    public init(searchQuery: String) {
        self.searchQuery = searchQuery
    }

    public enum CodingKeys: String, CodingKey, CaseIterable {
        case searchQuery
    }

    // Encodable protocol methods

    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(searchQuery, forKey: .searchQuery)
    }
}

