//
//  APITests.swift
//  NetworkExampleTests
//
//  Created by Tyler Thompson on 3/28/20.
//  Copyright © 2020 Tyler Thompson. All rights reserved.
//

import Foundation
import XCTest
import Combine

@testable import NetworkExample

extension API {
    struct JSONPlaceHolder: RESTAPIProtocol {
        var baseURL: String = "https://jsonplaceholder.typicode.com"
    }
}

class APITests:XCTestCase {
    var subscribers = Set<AnyCancellable>()
    
    override func setUp() {
        subscribers.forEach { $0.cancel() }
        subscribers.removeAll()
    }
    
    func testAPIMakesAGETRequest() {
        let json = """
        [
            {
                userId: 1,
                id: 1,
                title: "sunt aut facere repellat provident occaecati excepturi optio reprehenderit",
                body: "quia et suscipit suscipit recusandae consequuntur expedita et cum reprehenderit molestiae ut ut quas totam nostrum rerum est autem sunt rem eveniet architecto"
            },
        ]
        """.data(using: .utf8)!
        StubAPIResponse(request: .init(.get, urlString: "https://jsonplaceholder.typicode.com/posts"),
                        statusCode: 200,
                        result: .success(json))
        
        let api = API.JSONPlaceHolder()
        
        var GETFinished = false
        api.get(endpoint: "posts")
            .sink(receiveCompletion: { (completion) in
                switch completion {
                case .finished: GETFinished = true
                case .failure: XCTFail("Call should succeed")
                }
            }) { (value) in
                XCTAssertEqual((value.response as? HTTPURLResponse)?.statusCode, 200)
                XCTAssertEqual(String(data: value.data, encoding: .utf8), String(data: json, encoding: .utf8))
            }.store(in: &subscribers)
        waitUntil(GETFinished)
        XCTAssert(GETFinished)
    }
    
    func testAPIThrowsErrorWhenGETtingWithInvalidURL() {
        var api = API.JSONPlaceHolder()
        api.baseURL = "FA KE"
        
        var GETFinished = false
        api.get(endpoint: "notreal")
            .sink(receiveCompletion: { (completion) in
                GETFinished = true
                switch completion {
                case .finished: XCTFail("Should have thrown error")
                case .failure(let error):
                    XCTAssertEqual((error as? API.URLError), API.URLError.unableToCreateURL)
                }
            }, receiveValue: { _ in })
            .store(in: &subscribers)
        waitUntil(GETFinished)
        XCTAssert(GETFinished)
    }
    
    func testAPIMakesAPOSTRequest() {
        let json = UUID().uuidString.data(using: .utf8)!
        let sentBody = try? JSONSerialization.data(withJSONObject: ["" : ""], options: [])
        StubAPIResponse(request: .init(.post,
                                       urlString: "https://jsonplaceholder.typicode.com/posts"),
                        statusCode: 201,
                        result: .success(json))
            .thenVerifyRequest { request in
                XCTAssertEqual(request.httpMethod, "POST")
                XCTAssertEqual(request.bodySteamAsData(), sentBody)
            }
        
        let api = API.JSONPlaceHolder()
        
        var POSTFinished = false
        api.post(endpoint: "posts", body: sentBody)
            .sink(receiveCompletion: { (completion) in
                switch completion {
                case .finished: POSTFinished = true
                case .failure: XCTFail("Call should succeed")
                }
            }) { (value) in
                XCTAssertEqual((value.response as? HTTPURLResponse)?.statusCode, 201)
                XCTAssertEqual(String(data: value.data, encoding: .utf8), String(data: json, encoding: .utf8))
            }.store(in: &subscribers)
        waitUntil(POSTFinished)
        XCTAssert(POSTFinished)
    }
    
    func testAPIThrowsErrorWhenPOSTtingWithInvalidURL() {
        var api = API.JSONPlaceHolder()
        api.baseURL = "FA KE"
        
        var POSTFinished = false
        api.post(endpoint: "notreal", body: nil)
            .sink(receiveCompletion: { (completion) in
                POSTFinished = true
                switch completion {
                case .finished: XCTFail("Should have thrown error")
                case .failure(let error):
                    XCTAssertEqual((error as? API.URLError), API.URLError.unableToCreateURL)
                }
            }, receiveValue: { _ in })
            .store(in: &subscribers)
        waitUntil(POSTFinished)
        XCTAssert(POSTFinished)
    }
    
    func testAPIMakesAPUTRequest() {
        let json = UUID().uuidString.data(using: .utf8)!
        let sentBody = try? JSONSerialization.data(withJSONObject: ["" : ""], options: [])
        StubAPIResponse(request: .init(.put,
                                       urlString: "https://jsonplaceholder.typicode.com/posts/1"),
                        statusCode: 200,
                        result: .success(json))
            .thenVerifyRequest { request in
                XCTAssertEqual(request.httpMethod, "PUT")
                XCTAssertEqual(request.bodySteamAsData(), sentBody)
            }
        
        let api = API.JSONPlaceHolder()
        
        var PUTFinished = false
        api.put(endpoint: "posts/1", body: sentBody)
            .sink(receiveCompletion: { (completion) in
                switch completion {
                case .finished: PUTFinished = true
                case .failure: XCTFail("Call should succeed")
                }
            }) { (value) in
                XCTAssertEqual((value.response as? HTTPURLResponse)?.statusCode, 200)
                XCTAssertEqual(String(data: value.data, encoding: .utf8), String(data: json, encoding: .utf8))
            }.store(in: &subscribers)
        waitUntil(PUTFinished)
        XCTAssert(PUTFinished)
    }
    
    func testAPIThrowsErrorWhenPUTtingWithInvalidURL() {
        var api = API.JSONPlaceHolder()
        api.baseURL = "FA KE"
        
        var PUTFinished = false
        api.put(endpoint: "notreal", body: nil)
            .sink(receiveCompletion: { (completion) in
                PUTFinished = true
                switch completion {
                case .finished: XCTFail("Should have thrown error")
                case .failure(let error):
                    XCTAssertEqual((error as? API.URLError), API.URLError.unableToCreateURL)
                }
            }, receiveValue: { _ in })
            .store(in: &subscribers)
        waitUntil(PUTFinished)
        XCTAssert(PUTFinished)
    }
    
    func testAPIMakesAPATCHRequest() {
        let json = UUID().uuidString.data(using: .utf8)!
        let sentBody = try? JSONSerialization.data(withJSONObject: ["" : ""], options: [])
        StubAPIResponse(request: .init(.patch,
                                       urlString: "https://jsonplaceholder.typicode.com/posts/1"),
                        statusCode: 200,
                        result: .success(json))
            .thenVerifyRequest { request in
                XCTAssertEqual(request.httpMethod, "PATCH")
                XCTAssertEqual(request.bodySteamAsData(), sentBody)
            }
        
        let api = API.JSONPlaceHolder()
        
        var PATCHFinished = false
        api.patch(endpoint: "posts/1", body: sentBody)
            .sink(receiveCompletion: { (completion) in
                switch completion {
                case .finished: PATCHFinished = true
                case .failure: XCTFail("Call should succeed")
                }
            }) { (value) in
                XCTAssertEqual((value.response as? HTTPURLResponse)?.statusCode, 200)
                XCTAssertEqual(String(data: value.data, encoding: .utf8), String(data: json, encoding: .utf8))
            }.store(in: &subscribers)
        waitUntil(PATCHFinished)
        XCTAssert(PATCHFinished)
    }
    
    func testAPIThrowsErrorWhenPATCHingWithInvalidURL() {
        var api = API.JSONPlaceHolder()
        api.baseURL = "FA KE"
        
        var PATCHFinished = false
        api.patch(endpoint: "notreal", body: nil)
            .sink(receiveCompletion: { (completion) in
                PATCHFinished = true
                switch completion {
                case .finished: XCTFail("Should have thrown error")
                case .failure(let error):
                    XCTAssertEqual((error as? API.URLError), API.URLError.unableToCreateURL)
                }
            }, receiveValue: { _ in })
            .store(in: &subscribers)
        waitUntil(PATCHFinished)
        XCTAssert(PATCHFinished)
    }
    
    func testAPIMakesADELETERequest() {
        let json = UUID().uuidString.data(using: .utf8)!
        StubAPIResponse(request: .init(.delete, urlString: "https://jsonplaceholder.typicode.com/posts/1"),
                        statusCode: 200,
                        result: .success(json))
        
        let api = API.JSONPlaceHolder()
        
        var DELETEFinished = false
        api.delete(endpoint: "posts/1")
            .sink(receiveCompletion: { (completion) in
                switch completion {
                case .finished: DELETEFinished = true
                case .failure: XCTFail("Call should succeed")
                }
            }) { (value) in
                XCTAssertEqual((value.response as? HTTPURLResponse)?.statusCode, 200)
                XCTAssertEqual(String(data: value.data, encoding: .utf8), String(data: json, encoding: .utf8))
            }.store(in: &subscribers)
        waitUntil(DELETEFinished)
        XCTAssert(DELETEFinished)
    }
    
    func testAPIThrowsErrorWhenDELETEingWithInvalidURL() {
        var api = API.JSONPlaceHolder()
        api.baseURL = "FA KE"
        
        var DELETEFinished = false
        api.delete(endpoint: "notreal")
            .sink(receiveCompletion: { (completion) in
                DELETEFinished = true
                switch completion {
                case .finished: XCTFail("Should have thrown error")
                case .failure(let error):
                    XCTAssertEqual((error as? API.URLError), API.URLError.unableToCreateURL)
                }
            }, receiveValue: { _ in })
            .store(in: &subscribers)
        waitUntil(DELETEFinished)
        XCTAssert(DELETEFinished)
    }
}
