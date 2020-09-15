//
//  IdentityServiceTests.swift
//  NetworkExampleTests
//
//  Created by Tyler Thompson on 3/29/20.
//  Copyright © 2020 Tyler Thompson. All rights reserved.
//

import Foundation
import XCTest

@testable import NetworkExample

class IdentityServiceTests: XCTestCase {
    
    func testIdentityServiceUsesURLSessionDefaultConfiguration() {
        XCTAssertEqual(API.IdentityService().urlSession, URLSession.shared)
    }
    
    func testProfileIsFetchedFromAPI() {
        let response = StubAPIResponse(request: .init(.get, urlString: "\(API.IdentityService().baseURL)/me"),
                                       statusCode: 200,
                                       result: .success(validProfileJSON.data(using: .utf8)!))
        
        var api = API.IdentityService(urlSession: response.session)
        
        var called = false
        api.fetchProfile { (result) in
            switch result {
                case .success(let profile):
                    XCTAssertEqual(profile.firstName, "Joe")
                    XCTAssertEqual(profile.lastName, "Zztest")
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
        }
        
        waitUntil(0.3, called)
        XCTAssert(called)
    }
    
    func testFetchProfileThrowsAPIBorkedError() {
        let response = StubAPIResponse(request: .init(.get, urlString: "\(API.IdentityService().baseURL)/me"),
                                       statusCode: 200,
                                       result: .success(Data("Invalid".utf8)))
        
        var api = API.IdentityService(urlSession: response.session)
        
        var called = false
        api.fetchProfile { (result) in
            switch result {
                case .success(_): XCTFail("Should not have a successful profile")
                case .failure(let error):
                    XCTAssertEqual(API.IdentityService.FetchProfileError.apiBorked, error)
            }
            called = true
        }
        
        waitUntil(0.3, called)
        XCTAssert(called)
    }
    
    func testFetchProfileRetriesOnUnauthorizedResponse() {
        let response = StubAPIResponse(request: .init(.get, urlString: "\(API.IdentityService().baseURL)/me"),
                                       statusCode: 401)
                        .thenRespondWith(request: .init(.post,
                                                        urlString: "\(API.IdentityService().baseURL)/auth/refresh",
                            body: try? JSONSerialization.data(withJSONObject: ["refreshToken":User.refreshToken], options: [])),
                                         statusCode: 200,
                                         result: .success(validRefreshResponse))
                        .thenRespondWith(request: .init(.get, urlString: "\(API.IdentityService().baseURL)/me"),
                                         statusCode: 200,
                                         result: .success(validProfileJSON.data(using: .utf8)!))
        
        var api = API.IdentityService(urlSession: response.session)
        
        var called = false
        api.fetchProfile { (result) in
            switch result {
                case .success(let profile): XCTAssertEqual(profile.firstName, "Joe")
                case .failure(_):
                    XCTFail("Should not have an error")
            }
            called = true
        }
        
        waitUntil(called)
        XCTAssert(called)
    }
    
    func testFetchProfileFailsOnUnauthorizedResponseIfRefreshFails() {
        let response = StubAPIResponse(request: .init(.get, urlString: "\(API.IdentityService().baseURL)/me"),
                                       statusCode: 401)
                        .thenRespondWith(request: .init(.post, urlString: "\(API.IdentityService().baseURL)/auth/refresh"),
                                         statusCode: 200,
                                         result: .success(Data("".utf8)))
                        .thenRespondWith(request: .init(.get, urlString: "\(API.IdentityService().baseURL)/me"),
                                         statusCode: 200,
                                         result: .success(validProfileJSON.data(using: .utf8)!))
        
        var api = API.IdentityService(urlSession: response.session)
        
        var called = false
        api.fetchProfile { (result) in
            switch result {
                case .success(_): XCTFail("Should not have successful response")
                case .failure(let error):
                    XCTAssertEqual(API.IdentityService.FetchProfileError.apiBorked, error)
            }
            called = true
        }
        
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
                "lastName": "Zztest",
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
