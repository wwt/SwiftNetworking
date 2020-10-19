//
//  URLRequestExtensions.swift
//  NetworkExample
//
//  Created by Tyler Thompson on 3/29/20.
//  Copyright © 2020 Tyler Thompson. All rights reserved.
//

import Foundation
extension URLRequest {
    func addingBearerAuthorization(token: String) -> URLRequest {
        var request = self
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        return request
    }
    func acceptingJSON() -> URLRequest {
        var request = self
        request.setValue("application/json", forHTTPHeaderField: "Accept")
        return request
    }
    func sendingJSON() -> URLRequest {
        var request = self
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        return request
    }
}
