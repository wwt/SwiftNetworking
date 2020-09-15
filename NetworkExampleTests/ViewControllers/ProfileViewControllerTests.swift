//
//  ProfileViewControllerTests.swift
//  NetworkExampleTests
//
//  Created by Tyler Thompson on 4/1/20.
//  Copyright © 2020 Tyler Thompson. All rights reserved.
//

import Foundation
import XCTest
import Swinject
import Cuckoo

@testable import NetworkExample

class ProfileViewControllerTests: XCTestCase {
    func testFetchingProfileFromAPI() {
        let mock = MockIdentityServiceProtocol()
            .registerIn(container: API.container)
        let expectedProfile = User.Profile.createForTests()
                
        stub(mock) { stub in
            when(stub.fetchProfile(any())).then { (callback) in
                callback(.success(expectedProfile))
            }
        }
        
        let testViewController = ProfileViewController()
        
        testViewController.fetchProfile()
        
        verify(mock, times(1)).fetchProfile(any())
        XCTAssertEqual(testViewController.nameLabelText, expectedProfile.firstName)
    }
}
