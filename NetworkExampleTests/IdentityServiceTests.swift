//
//  IdentityServiceTests.swift
//  NetworkExampleTests
//
//  Created by Tyler Thompson on 3/29/20.
//  Copyright © 2020 Tyler Thompson. All rights reserved.
//

import Foundation
import XCTest
import Combine

@testable import NetworkExample

class IdentityServiceTests: XCTestCase {
    var ongoingCalls = Set<AnyCancellable>()
    
    override func setUp() {
        ongoingCalls.forEach { $0.cancel() }
        ongoingCalls.removeAll()
    }
    
    func testIdentityServiceUsesURLSessionDefaultConfiguration() {
        XCTAssertEqual(API.IdentityService().urlSession, URLSession.shared)
    }
    
    func testProfileIsFetchedFromAPI() {
        StubAPIResponse(request: .init(.get, urlString: "\(API.IdentityService().baseURL)/me"),
                        statusCode: 200,
                        result: .success(validProfileJSON.data(using: .utf8)!))
        
        let api = API.IdentityService()
        
        var called = false
        api.fetchProfile.sink { (result) in
            switch result {
            case .success(let profile):
                XCTAssertEqual(profile.firstName, "Joe")
                XCTAssertEqual(profile.lastName, "Blow")
                XCTAssertEqual(profile.preferredName, "Zarathustra, Maestro of Madness")
                XCTAssertEqual(profile.email, "Tyler.Keith.Thompson@gmail.com")
                XCTAssertEqual(profile.dateOfBirth, DateFormatter("yyyy-MM-dd'T'HH:mm:ss").date(from: "1990-03-26T00:00:00"))
                XCTAssertEqual(profile.createdDate, DateFormatter("yyyy-MM-dd'T'HH:mm:ss.SSS").date(from: "2018-07-26T19:33:46.6818918"))
                XCTAssertEqual(profile.address?.line1, "111 Fake st")
                XCTAssertEqual(profile.address?.line2, "")
                XCTAssertEqual(profile.address?.city, "Denver")
                XCTAssertEqual(profile.address?.state, "CA")
                XCTAssertEqual(profile.address?.zip, "80202")
            case .failure(let error):
                XCTFail(error.localizedDescription)
            }
            called = true
        }.store(in: &ongoingCalls)
        
        waitUntil(0.3, called)
        XCTAssert(called)
    }
    
    func testFetchProfileThrowsAPIBorkedError() {
        StubAPIResponse(request: .init(.get, urlString: "\(API.IdentityService().baseURL)/me"),
                        statusCode: 200,
                        result: .success(Data("Invalid".utf8)))
        
        let api = API.IdentityService()
        
        var called = false
        api.fetchProfile.sink { (result) in
            switch result {
            case .success(_): XCTFail("Should not have a successful profile")
            case .failure(let error):
                XCTAssertEqual(API.IdentityService.FetchProfileError.apiBorked, error)
            }
            called = true
        }.store(in: &ongoingCalls)
        
        waitUntil(0.3, called)
        XCTAssert(called)
    }
    
    func testFetchProfileRetriesOnUnauthorizedResponse() {
        StubAPIResponse(request: .init(.get, urlString: "\(API.IdentityService().baseURL)/me"),
                        statusCode: 401)
            .thenRespondWith(request: .init(.post,
                                            urlString: "\(API.IdentityService().baseURL)/auth/refresh"),
                             statusCode: 200,
                             result: .success(validRefreshResponse))
            .thenVerifyRequest { request in
                XCTAssertEqual(request.httpMethod, "POST")
                XCTAssertEqual(request.bodySteamAsData(), try? JSONSerialization.data(withJSONObject: ["refreshToken":User.refreshToken], options: []))
            }
            .thenRespondWith(request: .init(.get, urlString: "\(API.IdentityService().baseURL)/me"),
                             statusCode: 200,
                             result: .success(validProfileJSON.data(using: .utf8)!))
            .thenVerifyRequest { request in
                XCTAssertEqual(request.httpMethod, "GET")
                XCTAssertEqual(request.value(forHTTPHeaderField: "Accept"), "application/json")
                XCTAssertEqual(request.value(forHTTPHeaderField: "Content-Type"), "application/json")
                XCTAssertEqual(request.value(forHTTPHeaderField: "Authorization"), "Bearer \(User.accessToken)")
            }
        
        let api = API.IdentityService()
        
        var called = false
        api.fetchProfile.sink { (result) in
            switch result {
            case .success(let profile): XCTAssertEqual(profile.firstName, "Joe")
            case .failure(_):
                XCTFail("Should not have an error")
            }
            called = true
        }.store(in: &ongoingCalls)
        
        waitUntil(called)
        XCTAssert(called)
    }
    
    func testFetchProfileFailsOnUnauthorizedResponseIfRefreshFails() {
        StubAPIResponse(request: .init(.get, urlString: "\(API.IdentityService().baseURL)/me"),
                        statusCode: 401)
            .thenRespondWith(request: .init(.post, urlString: "\(API.IdentityService().baseURL)/auth/refresh"),
                             statusCode: 200,
                             result: .success(Data("".utf8)))
            .thenRespondWith(request: .init(.get, urlString: "\(API.IdentityService().baseURL)/me"),
                             statusCode: 200,
                             result: .success(validProfileJSON.data(using: .utf8)!))
        
        let api = API.IdentityService()
        
        var called = false
        api.fetchProfile.sink { (result) in
            switch result {
            case .success(_): XCTFail("Should not have successful response")
            case .failure(let error):
                XCTAssertEqual(API.IdentityService.FetchProfileError.apiBorked, error)
            }
            called = true
        }.store(in: &ongoingCalls)
        
        waitUntil(called)
        XCTAssert(called)
    }
}

extension IdentityServiceTests {
    var validRefreshResponse:Data {
        Data("""
            {
                "result" : {
                    "accessToken" : "\(UUID().uuidString)"
                }
            }
            """.utf8)
    }
    
    var validProfileJSON:String {
        """
        {
            "self": {
                "firstName": "Joe",
                "lastName": "Blow",
                "preferredName": "Zarathustra, Maestro of Madness",
                "email": "Tyler.Keith.Thompson@gmail.com",
                "dateOfBirth": "1990-03-26T00:00:00",
                "gender": "male",
                "phoneNumber": "3033033333",
                "address": {
                    "line1": "111 Fake st",
                    "line2": "",
                    "city": "Denver",
                    "stateOrProvince": "CA",
                    "zipCode": "80202",
                    "countryCode": "US"
                }
            },
            "isVerified": true,
            "username": "Tyler.Keith.Thompson@gmail.com",
            "termsAcceptedDate": "2018-07-26T19:33:46.8381401",
            "isTermsAccepted": true,
            "createdDate": "2018-07-26T19:33:46.6818918",
        }
        """
    }
}
