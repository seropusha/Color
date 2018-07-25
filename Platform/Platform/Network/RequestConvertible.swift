//
//  RequestConvertible.swift
//  Platform
//
//  Created by Sergey Navka on 4/17/18.
//  Copyright © 2018 Cleveroad. All rights reserved.
//

import Moya

protocol RequestConvertible: TargetType {
    var needsAuthorization: Bool { get }
    var shouldRetry: Bool { get }
}

extension RequestConvertible {
    var baseURL: URL {
        fatalError("Use RequestConvertible in conjunction with NetworkProvider")
    }
    var headers: [String: String]? {
        return nil
    }
    var needsAuthorization: Bool {
        return false
    }
    var shouldRetry: Bool {
        return true
    }
    var sampleData: Data {
        fatalError("Not implemented")
    }
}
