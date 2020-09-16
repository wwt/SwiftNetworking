//
//  MockAPIResponse.swift
//  NetworkExampleTests
//
//  Created by Tyler Thompson on 3/28/20.
//  Copyright © 2020 Tyler Thompson. All rights reserved.
//

import Foundation
import Combine
import Swinject
import XCTest

@testable import NetworkExample

extension URLRequest {
    var containerName:String {
        [httpMethod, url?.absoluteString].compactMap { $0 }.joined(separator: "_")
    }
}

extension Array {
    mutating func popLastUnlessEmpty() -> Element? {
        if (count > 1) {
            return popLast()
        } else {
            return last
        }
    }
}

class StubAPIResponse {
    var results = [String: [Result<Data, Error>]]()
    var responses = [String: [URLResponse]]()
    var requests = [URLRequest]()
    
    init(request:URLRequest, statusCode:Int, result:Result<Data, Error>? = nil, headers:[String : String]? = nil) {
        thenRespondWith(request: request,
                        statusCode: statusCode, result: result,
                        headers: headers)
    }
    
    @discardableResult func thenRespondWith(request:URLRequest, statusCode:Int, result:Result<Data, Error>? = nil, headers:[String : String]? = nil) -> Self {
        guard let url = request.url else { return self }
        if let res = result {
            results[request.containerName, default: []].insert(res, at: 0)
        }
        responses[request.containerName, default: []].insert(HTTPURLResponse(url: url, statusCode: statusCode, httpVersion: "2.0", headerFields: headers)!, at: 0)
        requests.insert(request, at: 0)
        
        if let _ = self.results[request.containerName] {
            Container.default.register(Result<Data, Error>.self, name: request.containerName) { _ in
                self.results[request.containerName]!.popLastUnlessEmpty()!
            }
        }
        Container.default.register(URLResponse.self, name: request.containerName) { _ in
            self.responses[request.containerName]!.popLastUnlessEmpty()!
        }
        Container.default.register(URLRequest.self, name: request.containerName) { _ in
            self.requests.popLastUnlessEmpty()!
        }
        return self
    }
    
    var session:URLSession {
        let config = URLSessionConfiguration.ephemeral
        config.protocolClasses = [NetworkRequestCapturer.self]
        return URLSession(configuration: config)
    }
}


public final class NetworkRequestCapturer: URLProtocol {
    public override var cachedResponse: CachedURLResponse? { nil }
    public override var task: URLSessionTask? { nil }
    
    public override class func canInit(with request: URLRequest) -> Bool { true }
    
    public override class func canInit(with task: URLSessionTask) -> Bool { true }
    
    public override class func canonicalRequest(for request: URLRequest) -> URLRequest { request }
    
    public override func startLoading() {
        guard let _ = request.url else {
            self.client?.urlProtocol(self, didFailWithError: API.URLError.unableToCreateURL)
            self.client?.urlProtocolDidFinishLoading(self)
            return
        }
        
        let result = Container.default.resolve(Result<Data, Error>.self, name: request.containerName)
        if case .success(let data) = result {
            self.client?.urlProtocol(self, didLoad: data)
        }
        
        if let response = Container.default.resolve(URLResponse.self, name: request.containerName) {
            self.client?.urlProtocol(self,
                                     didReceive: response,
                                     cacheStoragePolicy: .notAllowed)
        }
        
        if case .failure(let error) = result {
            self.client?.urlProtocol(self, didFailWithError: error)
        }
        
        if let expectedRequest = Container.default.resolve(URLRequest.self, name: request.containerName) {
            XCTAssertEqual(request.httpMethod, expectedRequest.httpMethod)
            if let expectedBody = expectedRequest.httpBody {
                XCTAssertEqual(request.bodySteamAsData(), expectedBody)
            }
        }
        
        self.client?.urlProtocolDidFinishLoading(self)
    }
    
    public override func stopLoading() { }
}
