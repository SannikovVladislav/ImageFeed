//
//  ProfileImageService.swift
//  ImageFeed
//
//  Created by Владислав on 24.08.2025.
//

import Foundation

final class ProfileImageService {
    
    static let didChangeNotification = Notification.Name(rawValue: "ProfileImageProviderDidChange")
    
    static let shared = ProfileImageService()
    private init() {}
    
    private let urlSession = URLSession.shared
    private var task: URLSessionTask?
    private var lastUsername: String?
    private(set) var avatarURL: String?
    
    func fetchProfileImageURL(username: String, completion: @escaping (Result<String, Error>) -> Void) {
        assert(Thread.isMainThread)
        
        if lastUsername == username { return }
        task?.cancel()
        lastUsername = username
        
        //print("Fetching profile image for username: \(username)")
        
        guard let request = makeProfileImageRequest(username: username) else {
            completion(.failure(ProfileServiceError.invalidRequest))
            return
        }
        
        let task = urlSession.objectTask(for: request) { [weak self] (result: Result<UserResult, Error>) in
            DispatchQueue.main.async {
                guard let self = self else { return }
                
                switch result {
                case .success(let response):
                    let avatarURL = response.profileImage.small
                    //print("Successfully fetched avatar URL: \(avatarURL)")
                    self.avatarURL = avatarURL
                    completion(.success(avatarURL))
                    
                    NotificationCenter.default.post(
                        name: ProfileImageService.didChangeNotification,
                        object: self,
                        userInfo: ["URL": avatarURL]
                    )
                    
                case .failure(let error):
                    print("❌ [ProfileImageService] Network error: \(error.localizedDescription), username: \(username)")
                    self.lastUsername = nil
                    completion(.failure(error))
                }
                self.task = nil
            }
        }
        self.task = task
        task.resume()
    }
    
    private func makeProfileImageRequest(username: String) -> URLRequest? {
        guard let url = URL(string: "https://api.unsplash.com/users/\(username)") else {
            assertionFailure("Invalid URL for user profile")
            return nil
        }
        
        guard let token = OAuth2TokenStorage().token else {
            assertionFailure("Token not found")
            return nil
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        return request
    }
}

