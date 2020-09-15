//
//  UserProfileConvenience.swift
//  NetworkExampleTests
//
//  Created by Tyler Thompson on 4/3/20.
//  Copyright © 2020 Tyler Thompson. All rights reserved.
//

import Foundation
import Fakery

@testable import NetworkExample

extension User.Profile {
    static func createForTests(firstName:String = Faker().name.firstName(),
         DHomeID:String = UUID().uuidString,
         createdDate:Date = Date(),
         termsAccepted:Bool = true,
         isVerified:Bool = true,
         email:String = Faker().internet.email()) -> User.Profile {
        return try! JSONDecoder().decode(User.Profile.self, from: Data("""
        {
            "selfId": "\(DHomeID)",
            "self": {
                "firstName": "\(firstName)",
                "email": "\(email)",
            },
            "username": "\(email)",
            "isVerified": \(isVerified),
            "isTermsAccepted": \(termsAccepted),
            "createdDate": "\(DateFormatter("yyyy-MM-dd'T'HH:mm:ss.SSS").string(from: createdDate))",
        }
        """.utf8))
    }
}
