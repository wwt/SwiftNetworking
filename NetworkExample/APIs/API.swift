//
//  API.swift
//  NetworkExample
//
//  Created by Tyler Thompson on 3/28/20.
//  Copyright © 2020 Tyler Thompson. All rights reserved.
//

import Foundation
import Combine

protocol APIProtocol {
    typealias RequestModifier = ((URLRequest) -> URLRequest)
    
    var baseURL:String { get set }
    var urlSession:URLSession { get set }
}

enum APIError: Error {
    case unableToCreateURL
}

extension APIProtocol {
    func get(endpoint:String, requestModifier:@escaping RequestModifier = { $0 }) -> AnyPublisher<URLSession.DataTaskPublisher.Output, Error> {
        guard let url = URL(string: "\(baseURL)")?.appendingPathComponent(endpoint) else {
            return Fail<URLSession.DataTaskPublisher.Output, Error>(error: APIError.unableToCreateURL).eraseToAnyPublisher()
        }
        let request = URLRequest(url: url)
        return createPublisher(for: request, requestModifier: requestModifier)
    }
    
    func post(endpoint:String, body: Data?, requestModifier:@escaping RequestModifier = { $0 }) -> AnyPublisher<URLSession.DataTaskPublisher.Output, Error> {
        guard let url = URL(string: "\(baseURL)")?.appendingPathComponent(endpoint) else {
            return Fail<URLSession.DataTaskPublisher.Output, Error>(error: APIError.unableToCreateURL).eraseToAnyPublisher()
        }
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.httpBody = body
        return createPublisher(for: request, requestModifier: requestModifier)
    }

    func put(endpoint:String, body: Data?, requestModifier:@escaping RequestModifier = { $0 }) -> AnyPublisher<URLSession.DataTaskPublisher.Output, Error> {
        guard let url = URL(string: "\(baseURL)")?.appendingPathComponent(endpoint) else {
            return Fail<URLSession.DataTaskPublisher.Output, Error>(error: APIError.unableToCreateURL).eraseToAnyPublisher()
        }
        var request = URLRequest(url: url)
        request.httpMethod = "PUT"
        request.httpBody = body
        return createPublisher(for: request, requestModifier: requestModifier)
    }
    
    func patch(endpoint:String, body: Data?, requestModifier:@escaping RequestModifier = { $0 }) -> AnyPublisher<URLSession.DataTaskPublisher.Output, Error> {
        guard let url = URL(string: "\(baseURL)")?.appendingPathComponent(endpoint) else {
            return Fail<URLSession.DataTaskPublisher.Output, Error>(error: APIError.unableToCreateURL).eraseToAnyPublisher()
        }
        var request = URLRequest(url: url)
        request.httpMethod = "PATCH"
        request.httpBody = body
        return createPublisher(for: request, requestModifier: requestModifier)
    }
    
    func delete(endpoint:String, requestModifier:@escaping RequestModifier = { $0 }) -> AnyPublisher<URLSession.DataTaskPublisher.Output, Error> {
        guard let url = URL(string: "\(baseURL)")?.appendingPathComponent(endpoint) else {
            return Fail<URLSession.DataTaskPublisher.Output, Error>(error: APIError.unableToCreateURL).eraseToAnyPublisher()
        }
        var request = URLRequest(url: url)
        request.httpMethod = "DELETE"
        return createPublisher(for: request, requestModifier: requestModifier)
    }
    
    func createPublisher(for request:URLRequest, requestModifier:@escaping RequestModifier) -> AnyPublisher<(data: Data, response: URLResponse), Error> {
        let authorizedNetworking = compose(
            requestModifier,
            urlSession.erasedDataTaskPublisher(for:)
        )
        return authorizedNetworking(request)
    }
    
    private func compose<A, B, C>(
        _ f: @escaping (A) -> B,
        _ g: @escaping (B) -> C
    ) -> (A) -> C {
        return { g(f($0)) }
    }
}

//class API {
//    typealias RequestModifier = ((URLRequest) -> URLRequest)
//
//    enum APIError: Error {
//        case unableToCreateURL
//    }
//
//    private let baseURL:String
//    private(set) var urlSession:URLSession
//
//    init(baseURL: String, urlSession:URLSession = URLSession.shared) {
//        self.baseURL = baseURL
//        self.urlSession = urlSession
//    }
//
//    func get(endpoint:String, requestModifier:@escaping RequestModifier = { $0 }) -> AnyPublisher<URLSession.DataTaskPublisher.Output, Error> {
//        guard let url = URL(string: "\(baseURL)")?.appendingPathComponent(endpoint) else {
//            return Fail<URLSession.DataTaskPublisher.Output, Error>(error: APIError.unableToCreateURL).eraseToAnyPublisher()
//        }
//        let request = URLRequest(url: url)
//        return createPublisher(for: request, requestModifier: requestModifier)
//    }
//
//    func post(endpoint:String, body: Data?, requestModifier:@escaping RequestModifier = { $0 }) -> AnyPublisher<URLSession.DataTaskPublisher.Output, Error> {
//        guard let url = URL(string: "\(baseURL)")?.appendingPathComponent(endpoint) else {
//            return Fail<URLSession.DataTaskPublisher.Output, Error>(error: APIError.unableToCreateURL).eraseToAnyPublisher()
//        }
//        var request = URLRequest(url: url)
//        request.httpMethod = "POST"
//        request.httpBody = body
//        return createPublisher(for: request, requestModifier: requestModifier)
//    }
//
//    func put(endpoint:String, body: Data?, requestModifier:@escaping RequestModifier = { $0 }) -> AnyPublisher<URLSession.DataTaskPublisher.Output, Error> {
//        guard let url = URL(string: "\(baseURL)")?.appendingPathComponent(endpoint) else {
//            return Fail<URLSession.DataTaskPublisher.Output, Error>(error: APIError.unableToCreateURL).eraseToAnyPublisher()
//        }
//        var request = URLRequest(url: url)
//        request.httpMethod = "PUT"
//        request.httpBody = body
//        return createPublisher(for: request, requestModifier: requestModifier)
//    }
//
//    func patch(endpoint:String, body: Data?, requestModifier:@escaping RequestModifier = { $0 }) -> AnyPublisher<URLSession.DataTaskPublisher.Output, Error> {
//        guard let url = URL(string: "\(baseURL)")?.appendingPathComponent(endpoint) else {
//            return Fail<URLSession.DataTaskPublisher.Output, Error>(error: APIError.unableToCreateURL).eraseToAnyPublisher()
//        }
//        var request = URLRequest(url: url)
//        request.httpMethod = "PATCH"
//        request.httpBody = body
//        return createPublisher(for: request, requestModifier: requestModifier)
//    }
//
//    func delete(endpoint:String, requestModifier:@escaping RequestModifier = { $0 }) -> AnyPublisher<URLSession.DataTaskPublisher.Output, Error> {
//        guard let url = URL(string: "\(baseURL)")?.appendingPathComponent(endpoint) else {
//            return Fail<URLSession.DataTaskPublisher.Output, Error>(error: APIError.unableToCreateURL).eraseToAnyPublisher()
//        }
//        var request = URLRequest(url: url)
//        request.httpMethod = "DELETE"
//        return createPublisher(for: request, requestModifier: requestModifier)
//    }
//
//    func createPublisher(for request:URLRequest, requestModifier:@escaping RequestModifier) -> AnyPublisher<(data: Data, response: URLResponse), Error> {
//        let authorizedNetworking = compose(
//            requestModifier,
//            urlSession.erasedDataTaskPublisher(for:)
//        )
//        return authorizedNetworking(request)
//    }
//
//    private func compose<A, B, C>(
//        _ f: @escaping (A) -> B,
//        _ g: @escaping (B) -> C
//    ) -> (A) -> C {
//        return { g(f($0)) }
//    }
//}
//
extension URLSession {
    func erasedDataTaskPublisher(
        for request: URLRequest
    ) -> AnyPublisher<(data: Data, response: URLResponse), Error> {
        dataTaskPublisher(for: request)
            .mapError { $0 }
            .eraseToAnyPublisher()
    }
}
