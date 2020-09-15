//
//  DependencyInjected.swift
//  NetworkExample
//
//  Created by Tyler Thompson on 4/1/20.
//  Copyright © 2020 Tyler Thompson. All rights reserved.
//

import Foundation
import Swinject

@propertyWrapper
public struct DependencyInjected<Value> {
    let name:String?
    let container:Container
    
    public init(wrappedValue value: Value?) {
        name = nil
        container = API.container
    }
    public init(wrappedValue value: Value? = nil, name:String) {
        self.name = name
        container = API.container
    }

    public init(wrappedValue value: Value? = nil, container containerGetter:@autoclosure () -> Container, name:String? = nil) {
        self.name = name
        container = containerGetter()
    }

    public lazy var wrappedValue: Value? = {
        container.resolve(Value.self, name: name)
    }()
}
