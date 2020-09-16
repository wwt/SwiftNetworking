//
//  Address.swift
//  NetworkExample
//
//  Created by Tyler Thompson on 3/29/20.
//  Copyright © 2020 Tyler Thompson. All rights reserved.
//

import Foundation

struct Address : Codable, Equatable {
    enum CodingKeys: String, CodingKey {
        case line1
        case line2
        case city
        case state = "stateOrProvince"
        case zip = "zipCode"
    }
    
    var line1: String
    var line2: String
    var city: String
    var state: String
    var zip: String
}
