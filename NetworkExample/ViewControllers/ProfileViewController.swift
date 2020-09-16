//
//  ProfileViewController.swift
//  NetworkExample
//
//  Created by Tyler Thompson on 4/1/20.
//  Copyright © 2020 Tyler Thompson. All rights reserved.
//

import Foundation
import Combine
import Swinject

class ProfileViewController {
    
    @DependencyInjected var identityService:IdentityServiceProtocol?
    
    var nameLabelText:String = ""
    
    var currentNetworkCalls = Set<AnyCancellable>() //these get cleaned up when the ViewController does, canceling all network calls along the way
    
    func fetchProfile() {
        identityService?.fetchProfile.sink { [weak self] result in
            if case .success(let profile) = result {
                self?.nameLabelText = profile.firstName
            }
        }.store(in: &currentNetworkCalls)
    }
}
