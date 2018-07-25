//
//  DomainError.swift
//  Domain
//
//  Created by Sergey Navka on 4/17/18.
//  Copyright © 2018 Cleveroad. All rights reserved.
//

import Foundation

public enum Permission {
    case location(always: Bool)
    case notifications
    case gallery
}

public enum DomainError: Error {
    case api(APIResponseError)
//    case underlying(Error)
//    case emailNotConfirmed(String)
//    case customMessage(String)
//    case userRequired
//    case `internal`
    case permissionDenied(Permission)
//    case paymentCardNotFound
}

extension DomainError: LocalizedError {
    public var errorDescription: String? {
        switch self {
        case .api(let error):
            return error.localizedDescription
//        case .underlying(let error):
//            return error.localizedDescription
//        case .emailNotConfirmed(let description):
//            return description
//        case .customMessage(let message):
//            return message
        case .permissionDenied(let permission):
            return "Unhandled permission error \(permission)"
//        default:
//            return "Something went wrong"
        }
    }
}
