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
    
    var currentNetworkCalls = Set<AnyCancellable>()
    
    func fetchProfile() {
        identityService?.fetchProfile.sink {
            if case .success(let profile) = $0 {
                self.nameLabelText = profile.firstName
            }
        }.store(in: &currentNetworkCalls)
    }
    
    func viewWillDisappear() {
        currentNetworkCalls.forEach { $0.cancel() }
        currentNetworkCalls.removeAll() //destroy any ongoing calls if the screen is transitioning
    }
}
