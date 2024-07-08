//
// MultimediaObjectResponse.swift
//
// Generated by openapi-generator
// https://openapi-generator.tech
//

import Foundation
#if canImport(AnyCodable)
import AnyCodable
#endif

public struct MultimediaObjectResponse: Codable, JSONEncodable, Hashable {

    public enum ModelType: String, Codable, CaseIterable {
        case image = "IMAGE"
        case video = "VIDEO"
        case text = "TEXT"
        case audio = "AUDIO"
        case multidimensional = "MULTIDIMENSIONAL"
    }
    public var id: String?
    public var type: ModelType?
    public var data: String?
    public var title: String?
    public var date: String?
    public var source: String?
    public var position: MultimediaObjectPosition?
    public var author: String?
    public var tags: [String]?

    public init(id: String? = nil, type: ModelType? = nil, data: String? = nil, title: String? = nil, date: String? = nil, source: String? = nil, position: MultimediaObjectPosition? = nil, author: String? = nil, tags: [String]? = nil) {
        self.id = id
        self.type = type
        self.data = data
        self.title = title
        self.date = date
        self.source = source
        self.position = position
        self.author = author
        self.tags = tags
    }

    public enum CodingKeys: String, CodingKey, CaseIterable {
        case id
        case type
        case data
        case title
        case date
        case source
        case position
        case author
        case tags
    }

    // Encodable protocol methods

    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encodeIfPresent(id, forKey: .id)
        try container.encodeIfPresent(type, forKey: .type)
        try container.encodeIfPresent(data, forKey: .data)
        try container.encodeIfPresent(title, forKey: .title)
        try container.encodeIfPresent(date, forKey: .date)
        try container.encodeIfPresent(source, forKey: .source)
        try container.encodeIfPresent(position, forKey: .position)
        try container.encodeIfPresent(author, forKey: .author)
        try container.encodeIfPresent(tags, forKey: .tags)
    }
}

