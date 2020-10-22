//
//  URLSessionExtensions.swift
//  NetworkExample
//
//  Created by Tyler Thompson on 3/28/20.
//  Copyright © 2020 World Wide Technology. All rights reserved..
//

import Foundation
import Combine

extension URLSession {
    typealias ErasedDataTaskPublisher = AnyPublisher<(data: Data, response: URLResponse), Error>
    
    func erasedDataTaskPublisher(
        for request: URLRequest
    ) -> ErasedDataTaskPublisher {
        dataTaskPublisher(for: request)
            .mapError { $0 }
            .eraseToAnyPublisher()
    }
}
