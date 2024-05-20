//
// MultimediaObjectPosition.swift
//
// Generated by openapi-generator
// https://openapi-generator.tech
//

import Foundation
#if canImport(AnyCodable)
import AnyCodable
#endif

public struct MultimediaObjectPosition: Codable, JSONEncodable, Hashable {

    public var lat: Double
    public var lng: Double
    public var bearing: Int?
    public var yaw: Float?

    public init(lat: Double, lng: Double, bearing: Int? = nil, yaw: Float? = nil) {
        self.lat = lat
        self.lng = lng
        self.bearing = bearing
        self.yaw = yaw
    }

    public enum CodingKeys: String, CodingKey, CaseIterable {
        case lat
        case lng
        case bearing
        case yaw
    }

    // Encodable protocol methods

    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(lat, forKey: .lat)
        try container.encode(lng, forKey: .lng)
        try container.encodeIfPresent(bearing, forKey: .bearing)
        try container.encodeIfPresent(yaw, forKey: .yaw)
    }
}

