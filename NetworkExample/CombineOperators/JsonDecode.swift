//
//  JsonDecode.swift
//  NetworkExample
//
//  Created by Tyler Thompson on 4/3/20.
//  Copyright © 2020 Tyler Thompson. All rights reserved.
//

import Foundation
import Combine

extension Publisher {
    public func decodeFromJson<Item>(_ type: Item.Type) -> Publishers.Decode<Self, Item, JSONDecoder> where Item : Decodable, Self.Output == JSONDecoder.Input {
        return decode(type: type, decoder: JSONDecoder())
    }
}
