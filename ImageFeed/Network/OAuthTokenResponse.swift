//
//  OAuthTokenResponse.swift
//  ImageFeed
//
//  Created by Владислав on 14.08.2025.
//

import Foundation

struct OAuthTokenResponseBody: Decodable {
    let accessToken: String
    let tokenType: String
    let scope: String
    let createdAt: Int
}
