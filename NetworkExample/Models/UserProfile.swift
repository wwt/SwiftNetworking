//
//  UserProfile.swift
//  NetworkExample
//
//  Created by Tyler Thompson on 3/29/20.
//  Copyright © 2020 World Wide Technology. All rights reserved..
//

import Foundation

extension User {
    class Profile:Decodable {
        var firstName:String
        var lastName: String?
        var preferredName: String?
        var createdDate: Date
        var address: Address?
        var isVerified: Bool
        var email: String
        var dateOfBirth: Date?
        
        required init(from decoder: Decoder) throws {
            let values = try decoder.container(keyedBy: CodingKeys.self)
            let dateString = try values.decode(String.self, forKey: .createdDate)
            if let date = DateFormatter("yyyy-MM-dd'T'HH:mm:ss.SSS").date(from: dateString) {
                createdDate = date
            } else {
                throw DecodingError.typeMismatch(Date.self,
                                                 DecodingError.Context(codingPath: [CodingKeys.createdDate],
                                                                       debugDescription: "Unable to parse createdDate with Date formatter (yyyy-MM-dd'T'HH:mm:ss.SSS)"))
            }
            
            isVerified = try values.decode(Bool.self, forKey: .isVerified)
            
            let selfContainer = try values.nestedContainer(keyedBy: SelfKeys.self, forKey: .selfObject)
            firstName = try selfContainer.decode(String.self, forKey: .firstName)
            lastName = try selfContainer.decodeIfPresent(String.self, forKey: .lastName)
            preferredName = try selfContainer.decodeIfPresent(String.self, forKey: .preferredName)
            email = try selfContainer.decode(String.self, forKey: .email)
            address = try selfContainer.decodeIfPresent(Address.self, forKey: .address)
            
            if let dateString = try selfContainer.decodeIfPresent(String.self, forKey: .dateOfBirth) {
                if let date = DateFormatter("yyyy-MM-dd'T'HH:mm:ss").date(from: dateString) {
                    dateOfBirth = date
                } else {
                    throw DecodingError.typeMismatch(Date.self,
                                                     DecodingError.Context(codingPath: [SelfKeys.dateOfBirth],
                                                                           debugDescription: "Unable to parse dateOfBirth with Date formatter (yyyy-MM-dd'T'HH:mm:ss)"))
                }
            }
        }
    }
}

extension User.Profile {
    enum CodingKeys: String, CodingKey {
        case createdDate
        case isVerified
        case selfObject = "self"
    }
    
    enum SelfKeys: String, CodingKey {
        case firstName
        case lastName
        case preferredName
        case email
        case dateOfBirth
        case address
    }
}
