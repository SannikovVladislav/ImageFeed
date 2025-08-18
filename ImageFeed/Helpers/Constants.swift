//
//  Constants.swift
//  ImageFeed
//
//  Created by Владислав on 31.07.2025.
//
import Foundation

enum Constants {
    static let accessKey = "KnQbhJO_cURlC40Ks5dYaL4fYk_FH52eh8SJncsB6eo"
    static let secretKey = "0r-FcCABEWWQsINji5BK71oAZ9Tz590cwglCDXlXkiE"
    static let redirectURI = "urn:ietf:wg:oauth:2.0:oob"
    static let accessScope = "public+read_user+write_likes"
    static let defaultBaseURL: URL = {
        guard let url = URL(string: "https://api.unsplash.com") else {
            fatalError("Invalid base URL")
        }
        return url
    }()
}
