//
//  AccessToken.swift
//  Platform
//
//  Created by Sergey Navka on 4/17/18.
//  Copyright © 2018 Cleveroad. All rights reserved.
//

import Foundation

class AccessToken: Codable {

    enum CodingKeys: String, CodingKey {
        case tokenString = "accessToken"
        case refreshTokenString = "refreshToken"
        case expirationDate = "expiresAt"
    }

    let tokenString: String
    let refreshTokenString: String
    private var expirationDate: Date

    var isValid: Bool {
        return expirationDate > Date()
    }

    func invalidate() {
        expirationDate = Date()
    }

    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)

        self.tokenString = try container.decode(String.self, forKey: .tokenString)
        self.refreshTokenString = try container.decode(String.self, forKey: .refreshTokenString)
        self.expirationDate = try Date(timeIntervalSince1970: TimeInterval(container.decode(Int64.self,
                                                                                            forKey: .expirationDate)) / 1000)
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(tokenString, forKey: .tokenString)
        try container.encode(refreshTokenString, forKey: .refreshTokenString)
        let expirationDateInMs: Int64 = Int64(expirationDate.timeIntervalSince1970 * 1000)
        try container.encode(expirationDateInMs, forKey: .expirationDate)
    }
}
