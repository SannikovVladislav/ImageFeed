//
//  ProfileService.swift
//  ImageFeed
//
//  Created by Владислав on 24.08.2025.
//

import Foundation

enum ProfileServiceError: Error {
    case invalidRequest
}

final class ProfileService {
    static let shared = ProfileService()
    private init() {}
    
    private let urlSession = URLSession.shared
    private var task: URLSessionTask?
    private(set) var profile: Profile?
    private var lastToken: String?
    
    func fetchProfile(token: String, completion: @escaping (Result<Profile, Error>) -> Void) {
        assert(Thread.isMainThread)
        
        guard lastToken != token else {
            completion(.failure(ProfileServiceError.invalidRequest))
            return
        }
        task?.cancel()
        self.task = nil
        lastToken = token
        
        guard let request = makeProfileRequest(token: token) else {
            completion(.failure(ProfileServiceError.invalidRequest))
            return
        }
        
        let task = urlSession.objectTask(for: request) { [weak self] (result: Result<ProfileResult, Error>) in
            DispatchQueue.main.async {
                guard let self = self else { return }
                
                switch result {
                case .success(let response):
                    let profile = Profile(profileResult: response)
                    self.profile = profile
                    completion(.success(profile))
                    
                case .failure(let error):
                    print("❌[ProfileService] Network error: \(error.localizedDescription), token: \(token)")
                    self.lastToken = nil
                    completion(.failure(error))
                }
                self.task = nil
            }
        }
        self.task = task
        task.resume()
    }
    
    private func makeProfileRequest(token: String) -> URLRequest? {
        guard let url = URL(string: "https://api.unsplash.com/me") else {
            assertionFailure("❌ Failed to create URL")
            return nil
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        return request
    }
    
    func deleteProfile() {
        task = nil
        profile = nil
        lastToken = nil
    }
}
