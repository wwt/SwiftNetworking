//
//  ProfileViewController.swift
//  NetworkExample
//
//  Created by Tyler Thompson on 4/1/20.
//  Copyright © 2020 Tyler Thompson. All rights reserved.
//

import Foundation
import Swinject

class ProfileViewController {
    
    @DependencyInjected var identityService:IdentityServiceProtocol?
    
    var nameLabelText:String = ""
    
    func fetchProfile() {
        identityService?.fetchProfile {
            if case .success(let profile) = $0 {
                self.nameLabelText = profile.firstName
            }
        }
    }
}
