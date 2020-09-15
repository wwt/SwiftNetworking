//
//  BaseAPI.swift
//  NetworkExample
//
//  Created by Tyler Thompson on 3/28/20.
//  Copyright © 2020 Tyler Thompson. All rights reserved.
//

import Foundation
import Swinject

struct API {
    enum URLError: Error {
        case unableToCreateURL
    }
    enum AuthorizationError:Error {
        case unauthorized
    }
    static var container = Container()
}
