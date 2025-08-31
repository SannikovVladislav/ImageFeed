//
//  OAuth2Service 2.swift
//  ImageFeed
//
//  Created by Владислав on 14.08.2025.
//

import Foundation

enum AuthServiceError: Error {
    case invalidRequest
}

final class OAuth2Service {
    
    private let urlSession = URLSession.shared
    private var task: URLSessionTask?
    private var lastCode: String?
    
    static let shared = OAuth2Service()
    
    private init() {}
    
    func fetchOAuthToken(code: String, completion: @escaping (Result<String, Error>) -> Void) {
        assert(Thread.isMainThread)
        
        guard lastCode != code else {
            completion(.failure(AuthServiceError.invalidRequest))
            return
        }
        
        task?.cancel()
        self.task = nil
        lastCode = code
        
        guard let request = makeOAuthTokenRequest(code: code) else {
            completion(.failure(AuthServiceError.invalidRequest))
            return
        }
        
        let task = URLSession.shared.objectTask(for: request) { [weak self] (result: Result<OAuthTokenResponseBody, Error>) in
            guard let self = self else { return }
            
            switch result {
            case .success(let response):
                completion(.success(response.accessToken))
            case .failure(let error):
                print("❌ [OAuth2Service] Network error: \(error.localizedDescription), code: \(code)")
                self.lastCode = nil
                completion(.failure(error))
            }
            self.task = nil
        }
        self.task = task
        task.resume()
    }
    private func makeOAuthTokenRequest(code: String) -> URLRequest? {
        
        guard URL(string: "https://unsplash.com/oauth/token") != nil else {
            assertionFailure("[OAuth2Service] Invalid URL")
            return nil
        }
        
        var urlComponents = URLComponents()
        urlComponents.scheme = "https"
        urlComponents.host = "unsplash.com"
        urlComponents.path = "/oauth/token"
        
        let queryItems = [
            URLQueryItem(name: "client_id", value: Constants.accessKey),
            URLQueryItem(name: "client_secret", value: Constants.secretKey),
            URLQueryItem(name: "redirect_uri", value: Constants.redirectURI),
            URLQueryItem(name: "code", value: code),
            URLQueryItem(name: "grant_type", value: "authorization_code")
        ]
        urlComponents.queryItems = queryItems
        guard let url = urlComponents.url else {
            print("[OAuth2Service] Invalid URL components")
            return nil
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        return request
    }
}
