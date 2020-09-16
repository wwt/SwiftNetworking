//
//  APIOperators.swift
//  NetworkExample
//
//  Created by thompsty on 9/14/20.
//  Copyright © 2020 Tyler Thompson. All rights reserved.
//

import Foundation
import Combine

extension URLSession.ErasedDataTaskPublisher {
    
    func unwrapResultJSONFromAPI() -> Self {
        map {
            if let json = try? JSONSerialization.jsonObject(with: $0.data, options: []) as? [String:Any],
               let result = (json["result"] as? [String:Any]),
               let data = try? JSONSerialization.data(withJSONObject: result, options: []) {
                return (data:data, response: $0.response)
            }
            return $0
        }.eraseToAnyPublisher()
    }
    
}
