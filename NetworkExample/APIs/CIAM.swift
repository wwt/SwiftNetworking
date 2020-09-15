//
//  CIAM.swift
//  NetworkExample
//
//  Created by Tyler Thompson on 3/28/20.
//  Copyright © 2020 Tyler Thompson. All rights reserved.
//

import Foundation
import Combine

extension API {
    struct IdentityService:APIProtocol {
        var baseURL: String = "https://stage.ciam.dignityhealth.org/api"
        
        var urlSession: URLSession = URLSession.shared
        
        var subscribers = Set<AnyCancellable>()
    }
}

class User {
    class Profile:Codable {
        var firstName:String = ""
    }
}

extension URLRequest {
    func addBearerAuthorization() -> URLRequest {
        var request = self
        let token = ""
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        return request
    }
    func acceptJSON() -> URLRequest {
        var request = self
        request.setValue("application/json", forHTTPHeaderField: "Accept")
        return request
    }
    func sendJSON() -> URLRequest {
        var request = self
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        return request
    }
}

extension API.IdentityService {
    mutating func fetchProfile(_ callback:@escaping (Result<User.Profile, Error>) -> Void) {
        get(endpoint: "users/me", requestModifier: {
            $0.addBearerAuthorization()
                .acceptJSON()
                .sendJSON()
        })
        .map { $0.data }
        .decode(type: User.Profile.self, decoder: JSONDecoder())
        .sink(receiveCompletion: { (completion) in
            if case .failure(let error) = completion {
                callback(.failure(error))
            }
        }, receiveValue: {
            callback(.success($0))
        }).store(in: &subscribers)
    }
}
