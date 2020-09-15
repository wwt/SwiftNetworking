//
//  DefaultContainer.swift
//  NetworkExampleTests
//
//  Created by Tyler Thompson on 3/28/20.
//  Copyright © 2020 Tyler Thompson. All rights reserved.
//

import Foundation
import Swinject

extension Container {
    static var `default`:Container = {
        return Container()
    }()
}
