//
//  ProfileResult.swift
//  ImageFeed
//
//  Created by Владислав on 24.08.2025.
//

import Foundation

struct ProfileResult: Decodable {
    let username: String
    let firstName: String?
    let lastName: String?
    let bio: String?
}
