//
//  APIProtocol.swift
//  NetworkExample
//
//  Created by Tyler Thompson on 3/28/20.
//  Copyright © 2020 Tyler Thompson. All rights reserved.
//

import Foundation
import Combine

protocol APIProtocol {
    typealias RequestModifier = ((URLRequest) -> URLRequest)
    
    var baseURL:String { get }
    var urlSession:URLSession { get }
}

extension APIProtocol {
    var urlSession: URLSession {
        URLSession.shared
    }
    
    func get(endpoint:String, requestModifier:@escaping RequestModifier = { $0 }) -> URLSession.ErasedDataTaskPublisher {
        guard let url = URL(string: "\(baseURL)")?.appendingPathComponent(endpoint) else {
            return Fail<URLSession.DataTaskPublisher.Output, Error>(error: API.URLError.unableToCreateURL).eraseToAnyPublisher()
        }
        let request = URLRequest(url: url)
        return createPublisher(for: request, requestModifier: requestModifier)
    }
    
    func put(endpoint:String, body: Data?, requestModifier:@escaping RequestModifier = { $0 }) -> URLSession.ErasedDataTaskPublisher {
        guard let url = URL(string: "\(baseURL)")?.appendingPathComponent(endpoint) else {
            return Fail<URLSession.DataTaskPublisher.Output, Error>(error: API.URLError.unableToCreateURL).eraseToAnyPublisher()
        }
        var request = URLRequest(url: url)
        request.httpMethod = "PUT"
        request.httpBody = body
        return createPublisher(for: request, requestModifier: requestModifier)
    }

    func post(endpoint:String, body: Data?, requestModifier:@escaping RequestModifier = { $0 }) -> URLSession.ErasedDataTaskPublisher {
        guard let url = URL(string: "\(baseURL)")?.appendingPathComponent(endpoint) else {
            return Fail<URLSession.DataTaskPublisher.Output, Error>(error: API.URLError.unableToCreateURL).eraseToAnyPublisher()
        }
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.httpBody = body
        return createPublisher(for: request, requestModifier: requestModifier)
    }
    
    func patch(endpoint:String, body: Data?, requestModifier:@escaping RequestModifier = { $0 }) -> URLSession.ErasedDataTaskPublisher {
        guard let url = URL(string: "\(baseURL)")?.appendingPathComponent(endpoint) else {
            return Fail<URLSession.DataTaskPublisher.Output, Error>(error: API.URLError.unableToCreateURL).eraseToAnyPublisher()
        }
        var request = URLRequest(url: url)
        request.httpMethod = "PATCH"
        request.httpBody = body
        return createPublisher(for: request, requestModifier: requestModifier)
    }
    
    func delete(endpoint:String, requestModifier:@escaping RequestModifier = { $0 }) -> URLSession.ErasedDataTaskPublisher {
        guard let url = URL(string: "\(baseURL)")?.appendingPathComponent(endpoint) else {
            return Fail<URLSession.DataTaskPublisher.Output, Error>(error: API.URLError.unableToCreateURL).eraseToAnyPublisher()
        }
        var request = URLRequest(url: url)
        request.httpMethod = "DELETE"
        return createPublisher(for: request, requestModifier: requestModifier)
    }
    
    func createPublisher(for request:URLRequest, requestModifier:@escaping RequestModifier) -> URLSession.ErasedDataTaskPublisher {
        Just(request).setFailureType(to: Error.self)
            .flatMap { request -> URLSession.ErasedDataTaskPublisher in
                return self.urlSession.erasedDataTaskPublisher(for: requestModifier(request))
        }.eraseToAnyPublisher()
    }
}
