//
//  ProfileLogoutService.swift
//  ImageFeed
//
//  Created by Владислав on 08.09.2025.
//
import Foundation
import WebKit

final class ProfileLogoutService {
    static let shared = ProfileLogoutService()
    
    let profileService = ProfileService.shared
    let profileImageService = ProfileImageService.shared
    let imagesListService = ImagesListService.shared
    let oauth2TokenStorage = OAuth2TokenStorage.shared
    
    private init() { }
    
    func logout() {
        cleanCookies()
        profileService.deleteProfile()
        profileImageService.deleteProfileImage()
        imagesListService.deleteImageList()
        oauth2TokenStorage.deleteOAuth2Token()
        
        DispatchQueue.main.async {
            guard let window = UIApplication.shared.windows.first else { return }
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            let authVC = storyboard.instantiateViewController(withIdentifier: "AuthViewController")
            window.rootViewController = SplashViewController()
        }
    }
    
    private func cleanCookies() {
        HTTPCookieStorage.shared.removeCookies(since: Date.distantPast)
        WKWebsiteDataStore.default().fetchDataRecords(ofTypes: WKWebsiteDataStore.allWebsiteDataTypes()){ records in
            records.forEach { record in
                WKWebsiteDataStore.default().removeData(ofTypes: record.dataTypes, for: [record], completionHandler: {})
            }
        }
    }
}

