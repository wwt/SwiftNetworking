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
import Combine

@testable import NetworkExample

class ProfileViewControllerTests: XCTestCase {
    func testFetchingProfileFromAPI() {
        let mock = MockIdentityServiceProtocol()
            .registerIn(container: API.container)
        let expectedProfile = User.Profile.createForTests()
        stub(mock) { stub in
            _ = when(stub.fetchProfile.get
                .thenReturn(Result.Publisher(.success(expectedProfile)).eraseToAnyPublisher()))
        }
        let testViewController = ProfileViewController()
        
        testViewController.fetchProfile()
        
        verify(mock, times(1)).fetchProfile.get()
        XCTAssertEqual(testViewController.nameLabelText, expectedProfile.firstName)
    }
    
    func testFetchingProfileDoesNotRetainAStrongReference() {
        let mock = MockIdentityServiceProtocol()
            .registerIn(container: API.container)
        let expectedProfile = User.Profile.createForTests()
        stub(mock) { stub in
            _ = when(stub.fetchProfile.get
                .thenReturn(Result.Publisher(.success(expectedProfile))
                                            .delay(for: .seconds(10), scheduler: RunLoop.main)
                                            .eraseToAnyPublisher()))
        }
        var testViewController:ProfileViewController? = ProfileViewController()
        weak var ref = testViewController
        testViewController?.fetchProfile()
        
        testViewController = nil
        
        verify(mock, times(1)).fetchProfile.get()
        XCTAssertNil(ref)
    }
}
