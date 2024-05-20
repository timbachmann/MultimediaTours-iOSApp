//
// MultimediaObjectRequest.swift
//
// Generated by openapi-generator
// https://openapi-generator.tech
//

import Foundation
#if canImport(AnyCodable)
import AnyCodable
#endif

public struct MultimediaObjectRequest: Codable, JSONEncodable, Hashable {

    public enum ModelType: String, Codable, CaseIterable {
        case image = "IMAGE"
        case video = "VIDEO"
        case text = "TEXT"
        case audio = "AUDIO"
        case multidimensional = "MULTIDIMENSIONAL"
    }
    public var type: ModelType
    public var title: String?
    public var date: String?
    public var source: String?
    public var position: MultimediaObjectPosition?
    public var data: String
    public var author: String?

    public init(type: ModelType, title: String? = nil, date: String? = nil, source: String? = nil, position: MultimediaObjectPosition? = nil, data: String, author: String? = nil) {
        self.type = type
        self.title = title
        self.date = date
        self.source = source
        self.position = position
        self.data = data
        self.author = author
    }

    public enum CodingKeys: String, CodingKey, CaseIterable {
        case type
        case title
        case date
        case source
        case position
        case data
        case author
    }

    // Encodable protocol methods

    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(type, forKey: .type)
        try container.encodeIfPresent(title, forKey: .title)
        try container.encodeIfPresent(date, forKey: .date)
        try container.encodeIfPresent(source, forKey: .source)
        try container.encodeIfPresent(position, forKey: .position)
        try container.encode(data, forKey: .data)
        try container.encodeIfPresent(author, forKey: .author)
    }
}
