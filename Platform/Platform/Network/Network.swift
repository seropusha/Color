//
//  Network.swift
//  Platform
//
//  Created by Sergey Navka on 4/17/18.
//  Copyright © 2018 Cleveroad. All rights reserved.
//

import Domain
import Reqres
import Moya
import Result

protocol RequestRetrier: class {
    func should(retry request: RequestConvertible, with error: MoyaError,
                completion: @escaping (Bool, DispatchTimeInterval) -> Void)
}

final class Network: RequestRetrier {
    
    private let baseURL: URL
    private let manager: Manager
    private let plugins: [PluginType]
    private let authPlugin = AuthPlugin()
    
    init(baseURL: URL) {
        self.baseURL = baseURL
        let configuration = Reqres.defaultSessionConfiguration()
        configuration.httpAdditionalHeaders = Manager.defaultHTTPHeaders
        configuration.timeoutIntervalForRequest = 30.0
        self.manager = Manager(configuration: configuration)
        self.plugins = [authPlugin, APIResponseErrorPlugin()]
    }
    
    func setAccessTokenProvider(_ accessTokenProvider: AccessTokenProvider) {
        authPlugin.accessTokenProvider = accessTokenProvider
    }
    
    func makeProvider<Target: RequestConvertible>() -> NetworkProvider<Target> {
        return NetworkProvider<Target>(baseURL: baseURL, manager: manager, plugins: plugins, requestRetrier: self)
    }
    
    func should(retry request: RequestConvertible, with error: MoyaError, completion: @escaping (Bool, DispatchTimeInterval) -> Void) {
        var shouldRefreshToken: Bool = false
        if error.response?.statusCode == 401 {
            shouldRefreshToken = true
        } else if case .underlying(let error, _) = error, let responseError = error as? APIResponseError {
            shouldRefreshToken = responseError.code == 401 || responseError.errors.first?.code == 400032
        }
        if shouldRefreshToken, let accessTokenProvider = authPlugin.accessTokenProvider {
            accessTokenProvider.refreshToken(else: error)
                .startWithResult { result in
                    switch result {
                    case .success:
                        completion(true, .seconds(0))
                    case .failure:
                        completion(false, .seconds(0))
                    }
            }
        } else {
            completion(false, .seconds(0))
        }
    }
}

final class AuthPlugin: PluginType {
    fileprivate weak var accessTokenProvider: AccessTokenProvider?
    
    init(_ accessTokenProvider: AccessTokenProvider? = nil) {
        self.accessTokenProvider = accessTokenProvider
    }
    
    func prepare(_ request: URLRequest, target: TargetType) -> URLRequest {
        guard let target = target as? RequestConvertible, target.needsAuthorization,
            let accessToken = accessTokenProvider?.accessToken.value?.tokenString else { return request }
        var updatedRequest = request
        updatedRequest.setValue(accessToken, forHTTPHeaderField: "Authorization")
        return updatedRequest
    }
}

final class APIResponseErrorPlugin: PluginType {
    func process(_ result: Result<Response, MoyaError>, target: TargetType) -> Result<Response, MoyaError> {
        guard case .success(let response) = result, 400 ..< 600 ~= response.statusCode else {
            return result
        }
        do {
            let responseError = try response.map(APIResponseError.self)
            return .failure(MoyaError.underlying(responseError, nil))
        } catch let error {
            return .failure(MoyaError.underlying(error, response))
        }
    }
}

final class NetworkProvider<Target: RequestConvertible>: MoyaProvider<Target> {
    
    private final class func endpointMapping(for baseURL: URL) -> (Target) -> Endpoint {
        return { target in
            return Endpoint(
                url: baseURL.appendingPathComponent(target.path).absoluteString,
                sampleResponseClosure: { .networkResponse(200, target.sampleData) },
                method: target.method,
                task: target.task,
                httpHeaderFields: target.headers
            )
        }
    }
    
    weak var requestRetrier: RequestRetrier?
    
    fileprivate init(baseURL: URL, manager: Manager, plugins: [PluginType], requestRetrier: RequestRetrier? = nil) {
        self.requestRetrier = requestRetrier
        super.init(endpointClosure: NetworkProvider.endpointMapping(for: baseURL), manager: manager, plugins: plugins)
    }
    
    @discardableResult
    override func request(_ target: Target,
                          callbackQueue: DispatchQueue? = .none,
                          progress: ProgressBlock? = .none,
                          completion: @escaping Completion) -> Moya.Cancellable {
        return super.request(target, callbackQueue: callbackQueue, progress: progress) { [weak self] result in
            guard let strongSelf = self else {
                completion(result)
                return
            }
            if case .failure(let error) = result, let requestRetrier = strongSelf.requestRetrier, target.shouldRetry {
                requestRetrier.should(retry: target, with: error, completion: { shouldRetry, delay in
                    if shouldRetry {
                        let callbackQueue = callbackQueue ?? .main
                        callbackQueue.asyncAfter(deadline: .now() + delay, execute: {
                            guard let strongSelf = self else {
                                completion(.failure(error))
                                return
                            }
                            strongSelf.request(target, callbackQueue: callbackQueue, progress: progress, completion: completion)
                        })
                        
                    } else {
                        completion(.failure(error))
                    }
                })
            } else {
                completion(result)
            }
        }
    }
}
