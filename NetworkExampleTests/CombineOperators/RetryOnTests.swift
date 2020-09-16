//
//  RetryOnTests.swift
//  NetworkExampleTests
//
//  Created by Tyler Thompson on 3/30/20.
//  Copyright © 2020 Tyler Thompson. All rights reserved.
//

import Foundation
import XCTest
import Combine

@testable import NetworkExample

class RetryOnTests:XCTestCase {
    var subscribers = Set<AnyCancellable>()
    
    func testRetryOnStartsTheChainOverIfTheErrorMatches() {
        enum Err: Error {
            case e1
            case e2
        }
        
        var called = 0
        
        let pub = TestPublisher<Int, Err> { s in
            s.receive(subscription: Subscriptions.empty)
            called += 1
            if (called > 3) { s.receive(completion: .finished) }
            s.receive(completion: .failure(Err.e1))
        }
        
        
        pub.retryOn(Err.e1, retries: 1)
            .sink(receiveCompletion: { _ in }, receiveValue: { _ in })
            .store(in: &subscribers)
        
        waitUntil(called > 0)
        XCTAssertEqual(called, 2)
    }
    
    func testRetryOnStartsTheChainOverTheSpecifiedNumberOfTimesIfTheErrorMatches() {
        enum Err: Error {
            case e1
            case e2
        }
        
        let attempts = UInt.random(in: 2...5)
        
        var called = 0
        
        let pub = TestPublisher<Int, Err> { s in
            s.receive(subscription: Subscriptions.empty)
            called += 1
            if (called > attempts) { s.receive(completion: .finished) }
            s.receive(completion: .failure(Err.e1))
        }
        
        
        pub.retryOn(Err.e1, retries: attempts)
            .sink(receiveCompletion: { _ in }, receiveValue: { _ in })
            .store(in: &subscribers)
        
        waitUntil(called > 0)
        XCTAssertEqual(called, Int(attempts)+1)
    }
    
    func testRetryOnChainsPublishersBeforeRetrying() {
        enum Err: Error {
            case e1
            case e2
        }
        
        var called = 0
        
        let refresh = Just(1)
            .setFailureType(to: Err.self)
            .tryMap { i -> Int in
                called += 1
                return i
            }.mapError { $0 as! Err }
            .eraseToAnyPublisher()
        
        Just(1)
            .setFailureType(to: Err.self)
            .tryMap { _ -> Int in
                throw Err.e1
            }.mapError { $0 as! Err}
            .retryOn(Err.e1, retries: 1, chainedRequest: refresh)
            .sink(receiveCompletion: { _ in }, receiveValue: { _ in })
            .store(in: &subscribers)
        
        waitUntil(called > 0)
        XCTAssertEqual(called, 1)
    }
    
    func testRetryOnDoesNotRetryIfErrorDoesNotMatch() {
        enum Err: Error {
            case e1
            case e2
        }
        
        var called = 0
        
        Just(1)
            .setFailureType(to: Err.self)
            .tryMap { _ -> Int in
                called += 1
                throw Err.e1
            }.mapError { $0 as! Err}
            .retryOn(Err.e2, retries: 1)
            .sink(receiveCompletion: { _ in }, receiveValue: { _ in })
            .store(in: &subscribers)
        
        waitUntil(called > 0)
        XCTAssertEqual(called, 1)
    }
}
