//
//  AccessTokenProvider.swift
//  Platform
//
//  Created by Sergey Navka on 4/17/18.
//  Copyright © 2018 Cleveroad. All rights reserved.
//

import ReactiveSwift
import Moya

protocol AccessTokenProvider: class {
    var accessToken: Property<AccessToken?> { get }
    func refreshToken(else error: Error) -> SignalProducer<Void, MoyaError>
}
