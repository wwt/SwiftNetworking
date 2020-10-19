//
//  URLRequestExtensionsTests.swift
//  NetworkExampleTests
//
//  Created by Tyler Thompson on 3/29/20.
//  Copyright © 2020 Tyler Thompson. All rights reserved.
//

import Foundation
import XCTest

@testable import NetworkExample

class URLExtensionsTests:XCTestCase {
    func testAddingAcceptJSONToURLRequest() {
        let request = URLRequest(.get, urlString: "https://www.google.com")
        XCTAssertEqual(request.acceptingJSON().value(forHTTPHeaderField: "Accept"), "application/json")
        XCTAssertNil(request.value(forHTTPHeaderField: "Accept"))
    }
    
    func testAddingContentTypeJSONToURLRequest() {
        let request = URLRequest(.get, urlString: "https://www.google.com")
        XCTAssertEqual(request.sendingJSON().value(forHTTPHeaderField: "Content-Type"), "application/json")
        XCTAssertNil(request.value(forHTTPHeaderField: "Content-Type"))
    }
}
