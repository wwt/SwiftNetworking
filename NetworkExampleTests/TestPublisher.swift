//
//  TestPublisher.swift
//  NetworkExampleTests
//
//  Created by Tyler Thompson on 3/30/20.
//  Copyright © 2020 World Wide Technology. All rights reserved..
//

import Foundation
import Combine

public class TestPublisher<Output, Failure: Error>: Publisher {
    let subscribeBody: (AnySubscriber<Output, Failure>) -> Void
    
    public init(_ subscribe: @escaping (AnySubscriber<Output, Failure>) -> Void) {
        self.subscribeBody = subscribe
    }
    
    public func receive<S: Subscriber>(subscriber: S) where Failure == S.Failure, Output == S.Input {
        self.subscribeBody(AnySubscriber(subscriber))
    }
}
