//
//  IdentityService.swift
//  NetworkExample
//
//  Created by Tyler Thompson on 3/28/20.
//  Copyright © 2020 Tyler Thompson. All rights reserved.
//

import Foundation
import Combine

protocol IdentityServiceProtocol {
    mutating func fetchProfile(_ callback:@escaping (Result<User.Profile, API.IdentityService.FetchProfileError>) -> Void)
}

extension API {
    struct IdentityService:APIProtocol {
        var baseURL: String = "https://some.identityservice.com/api"
        
        var urlSession: URLSession = URLSession.shared
        
        var subscribers = Set<AnyCancellable>()
    }
}

extension API.IdentityService: IdentityServiceProtocol {
    enum FetchProfileError: Error {
        case apiBorked
    }
    
    mutating func fetchProfile(_ callback:@escaping (Result<User.Profile, FetchProfileError>) -> Void) {
        get(endpoint: "/me", requestModifier: {
            $0.addBearerAuthorization(token: User.accessToken)
                .acceptJSON()
                .sendJSON()
        })  .retryOnceOnUnauthorizedResponse(chainedRequest: refresh)
            .unwrapResultFromAPI()
            .map { $0.data }
            .decodeFromJson(User.Profile.self)
            .sink(receiveCompletion: { (completion) in
                if case .failure(let error) = completion {
                    callback(.failure((error as? FetchProfileError) ?? .apiBorked))
                }
            }, receiveValue: {
                callback(.success($0))
            })
            .store(in: &subscribers)
    }
}

extension API.IdentityService {
    var refresh:URLSession.ErasedDataTaskPublisher {
        post(endpoint: "/auth/refresh", body: try? JSONSerialization.data(withJSONObject: ["refreshToken":User.refreshToken], options: []), requestModifier: {
            $0.acceptJSON()
                .sendJSON()
        }).unwrapResultFromAPI()
            .tryMap { v -> URLSession.ErasedDataTaskPublisher.Output in
                let json = try? JSONSerialization.jsonObject(with: v.data, options: []) as? [String:Any]
                guard let accessToken = json?["accessToken"] as? String else {
                    throw API.AuthorizationError.unauthorized
                }
                User.accessToken = accessToken
                return v
        }.eraseToAnyPublisher()
    }
}
