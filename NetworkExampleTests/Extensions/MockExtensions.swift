//
//  MockExtensions.swift
//  NetworkExampleTests
//
//  Created by Tyler Thompson on 4/1/20.
//  Copyright © 2020 World Wide Technology. All rights reserved..
//

import Foundation
import Cuckoo
import Swinject

extension Mock {
    @discardableResult
    func registerIn(container: Container) -> Self {
        guard let cast = self as? Self.MocksType else {
            return self
        }
        container.register(MocksType.self) {_ in
            return cast
        }
        return self
    }
}
