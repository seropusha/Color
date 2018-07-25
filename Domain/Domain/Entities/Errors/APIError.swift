//
//  APIError.swift
//  Domain
//
//  Created by Sergey Navka on 4/17/18.
//  Copyright © 2018 Cleveroad. All rights reserved.
//

import Foundation

public struct APIResponseError: Decodable, LocalizedError {
    public let code: Int
    public let message: String
    public let errors: [APIError]

    public var errorDescription: String? {
        return errors[0].errorDescription
    }

// sourcery:inline:auto:APIResponseError.AutoPublicStruct
// DO NOT EDIT
    public init(code: Int, 
            message: String, 
            errors: [APIError]
            ) {
        self.code = code
        self.message = message
        self.errors = errors
}
// sourcery:end
}

public struct APIError: Decodable, LocalizedError {
    public enum Key: String, Decodable {
        case email
        case password
        case unknown
    }

    enum CodingKeys: String, CodingKey {
        case code
        case message
        case key
    }

    public let code: Int
    public let message: String

    public let key: Key

    public var errorDescription: String? {
        return message
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)

        self.code = try container.decode(Int.self, forKey: .code)
        self.message = try container.decode(String.self, forKey: .message)
        self.key = (try? container.decode(Key.self, forKey: .key)) ?? .unknown
    }

// sourcery:inline:auto:APIError.AutoPublicStruct
// DO NOT EDIT
    public init(code: Int, 
            message: String, 
            key: Key
            ) {
        self.code = code
        self.message = message
        self.key = key
}
// sourcery:end
}
