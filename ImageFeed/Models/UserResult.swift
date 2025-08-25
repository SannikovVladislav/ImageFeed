//
//  UserResult.swift
//  ImageFeed
//
//  Created by Владислав on 24.08.2025.
//

import Foundation

struct UserResult: Codable {
    let profileImage: ProfileImage
    
    struct ProfileImage: Codable {
        let small: String
    }
}
