//
//  IdentityService.swift
//  NetworkExample
//
//  Created by Tyler Thompson on 3/28/20.
//  Copyright © 2020 World Wide Technology. All rights reserved..
//

import Foundation
import Combine

protocol IdentityServiceProtocol: RESTAPIProtocol {
    var fetchProfile: AnyPublisher<Result<User.Profile, API.IdentityService.FetchProfileError>, Never> { get }
}

extension IdentityServiceProtocol {
    var baseURL: String {
        "https://some.identityservice.com/api"
    }
    
    var fetchProfile: AnyPublisher<Result<User.Profile, API.IdentityService.FetchProfileError>, Never> {
        self.get(endpoint: "/me", requestModifier: {
            $0.addingBearerAuthorization(token: User.accessToken)
                .acceptingJSON()
                .sendingJSON()
        }).retryOnceOnUnauthorizedResponse(chainedRequest: refresh)
        .unwrapResultJSONFromAPI()
        .map { $0.data }
        .decodeFromJson(User.Profile.self)
        .receive(on: DispatchQueue.main)
        .map(Result.success)
        .catch { error in Just(.failure((error as? API.IdentityService.FetchProfileError) ?? .apiBorked)) }
        .eraseToAnyPublisher()
    }
    
    private var refresh:URLSession.ErasedDataTaskPublisher {
        post(endpoint: "/auth/refresh", body: try? JSONSerialization.data(withJSONObject: ["refreshToken":User.refreshToken], options: []), requestModifier: {
            $0.acceptingJSON()
                .sendingJSON()
        }).unwrapResultJSONFromAPI()
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

extension API {
    struct IdentityService: IdentityServiceProtocol {
        enum FetchProfileError: Error {
            case apiBorked
        }
    }
}
