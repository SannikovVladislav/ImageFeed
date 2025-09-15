//
//  Untitled.swift
//  ImageFeed
//
//  Created by Владислав on 07.09.2025.
//

import Foundation

enum ImagesListServiceError: Error {
    case invalidRequest
    case invalidToken
    case invalidURL
    case decodingError
}

class ImagesListService {
    private(set) var photos: [Photo] = []
    static let didChangeNotification = Notification.Name(rawValue: "ImagesListServiceDidChange")
    static let shared = ImagesListService()
    private let urlSession = URLSession.shared
    private var task: URLSessionTask?
    private let dateFormatter = ISO8601DateFormatter()    
    private var lastLoadedPage: Int?
    private let perPage = 10
        
    private init() {}
    
    func fetchPhotosNextPage() {
        guard task == nil else {return}
        
        let nextPage = (lastLoadedPage ?? 0) + 1
        
        guard let request = makePhotosRequest(page: nextPage, perPage: perPage) else {
            print("[ImagesListService] Invalid request")
            return
        }
        
        let task = urlSession.objectTask(for: request) { [weak self] (result: Result<[PhotoResult], Error>) in
            DispatchQueue.main.async {
                guard let self = self else { return }
                
                switch result {
                case .success(let photoResults):
                    let newPhotos = photoResults.map { photoResult in
                        return Photo(id: photoResult.id,
                                     size: CGSize(width: photoResult.width, height: photoResult.height),
                                     createdAt: self.dateFormatter.date(from: photoResult.createdAt),
                                     welcomeDescription: photoResult.description,
                                     thumbImageURL: photoResult.urls.thumb,
                                     largeImageURL: photoResult.urls.full,
                                     isLiked: photoResult.likedByUser)
                    }
                    self.lastLoadedPage = nextPage
                    self.photos.append(contentsOf: newPhotos)
                    
                    NotificationCenter.default.post(
                        name: ImagesListService.didChangeNotification,
                        object: self
                    )
                    
                case .failure(let error):
                    print("❌ [ImagesListService] Network error: \(error.localizedDescription)")
                }
                self.task = nil
            }
        }
        self.task = task
        task.resume()
    }
    
    private func makePhotosRequest(page: Int, perPage: Int) -> URLRequest? {
        guard let url = URL(string: "https://api.unsplash.com/photos") else {
            assertionFailure("[ImagesListService] Invalid URL")
            return nil
        }
        var urlComponents = URLComponents()
        urlComponents.scheme = "https"
        urlComponents.host = "api.unsplash.com"
        urlComponents.path = "/photos"
        
        let queryItems = [
            URLQueryItem(name: "page", value: "\(page)"),
            URLQueryItem(name: "per_page", value: "\(perPage)")
        ]
        urlComponents.queryItems = queryItems
        
        guard let url = urlComponents.url else {
            print("[ImagesListService] Invalid URL components")
            return nil
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue("Bearer \(OAuth2TokenStorage().token ?? "")", forHTTPHeaderField: "Authorization")
        return request
    }
    
    func changeLike(photoId: String, isLike: Bool, _ completion: @escaping (Result<Void, Error>) -> Void) {
        guard let token = OAuth2TokenStorage().token else {
            completion(.failure(ImagesListServiceError.invalidToken))
            return
        }
        
        let httpMethod = isLike ? "POST" : "DELETE"
        let urlString = "https://api.unsplash.com/photos/\(photoId)/like"
        
        guard let url = URL(string: urlString) else {
            completion(.failure(ImagesListServiceError.invalidURL))
            return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = httpMethod
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        
        let task = urlSession.dataTask(with: request) { [weak self] data, response, error in
            if let error = error {
                completion(.failure(error))
                return
            }
            
            guard let httpResponse = response as? HTTPURLResponse,
                  (200...299).contains(httpResponse.statusCode) else {
                completion(.failure(ImagesListServiceError.invalidRequest))
                return
            }
            
            DispatchQueue.main.async {
                guard let self else { return }
                if let index = self.photos.firstIndex(where: { $0.id == photoId }) {
                    var photo = self.photos[index]
                    photo.isLiked = isLike
                    self.photos[index] = photo
                    completion(.success(()))
                }
            }
        }
        task.resume()
    }
    
    func deleteImageList() {
        photos.removeAll()
        task = nil
        lastLoadedPage = nil
    }
}

