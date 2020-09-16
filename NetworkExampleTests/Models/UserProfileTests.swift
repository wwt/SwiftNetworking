//
//  UserProfileTests.swift
//  NetworkExampleTests
//
//  Created by Tyler Thompson on 4/3/20.
//  Copyright © 2020 Tyler Thompson. All rights reserved.
//

import Foundation
import XCTest

@testable import NetworkExample

class UserProfileTests: XCTestCase {
    func testProfileDecodedFromJSON() throws {
        let profile = try JSONDecoder().decode(User.Profile.self, from: validProfileJSON)
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
    }
    
    func testProfileDecodedFromMinimalJSON() throws {
        let profile = try JSONDecoder().decode(User.Profile.self, from: bareMinimum)
        XCTAssertEqual(profile.firstName, "Joe")
        XCTAssertEqual(profile.email, "Tyler.Keith.Thompson@gmail.com")
        XCTAssertEqual(profile.createdDate, DateFormatter("yyyy-MM-dd'T'HH:mm:ss.SSS").date(from: "2018-07-26T19:33:46.6818918"))
    }
    
    func testProfileCannotCreateIfInvalidDateFormatUsedForCreatedDate() {
        let data = Data(
            """
            {
                "self": {
                    "firstName": "Joe",
                    "email": "Tyler.Keith.Thompson@gmail.com",
                },
                "username": "Tyler.Keith.Thompson@gmail.com",
                "isVerified": true,
                "createdDate": "totallyfake",
            }
            """.utf8)
        
        XCTAssertThrowsError(try JSONDecoder().decode(User.Profile.self, from: data)) { error in
            XCTAssert(error is DecodingError)
            if let err = error as? DecodingError {
                switch (err) {
                case .typeMismatch(let type, let context):
                    XCTAssert(type is Date.Type)
                    XCTAssertEqual(User.Profile.CodingKeys.createdDate.rawValue, context.codingPath.first?.stringValue)
                default: XCTFail("Wrong error type, expected typeMismatch")
                }
            }
        }
    }
    
    func testProfileCannotCreateIfInvalidDateFormatUsedForDateOfBirth() {
        let data = Data(
            """
            {
                "self": {
                    "firstName": "Joe",
                    "email": "Tyler.Keith.Thompson@gmail.com",
                    "dateOfBirth": "invaliddate",
                },
                "username": "Tyler.Keith.Thompson@gmail.com",
                "isVerified": true,
                "createdDate": "2018-07-26T19:33:46.6818918",
            }
            """.utf8)
        
        XCTAssertThrowsError(try JSONDecoder().decode(User.Profile.self, from: data)) { error in
            XCTAssert(error is DecodingError)
            if let err = error as? DecodingError {
                switch (err) {
                case .typeMismatch(let type, let context):
                    XCTAssert(type is Date.Type)
                    XCTAssertEqual(User.Profile.SelfKeys.dateOfBirth.rawValue, context.codingPath.first?.stringValue)
                default: XCTFail("Wrong error type, expected typeMismatch")
                }
            }
        }
    }
}

extension UserProfileTests {
    var validProfileJSON:Data {
        Data("""
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
        """.utf8)
    }
    
    var bareMinimum:Data {
        Data("""
        {
            "self": {
                "firstName": "Joe",
                "email": "Tyler.Keith.Thompson@gmail.com",
            },
            "username": "Tyler.Keith.Thompson@gmail.com",
            "isVerified": true,
            "termsAcceptedDate": "2018-07-26T19:33:46.8381401",
            "isTermsAccepted": true,
            "createdDate": "2018-07-26T19:33:46.6818918",
        }
        """.utf8)
    }
}
