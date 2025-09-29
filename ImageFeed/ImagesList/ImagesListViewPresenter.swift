//
//  ImagesListViewPresenter.swift
//  ImageFeed
//
//  Created by Владислав on 25.09.2025.
//

import Foundation

protocol ImagesListViewPresenterProtocol: AnyObject {
    var photos: [Photo] { get }
    func viewDidLoad()
    func willDisplayCell(at indexPath: IndexPath)
    func didTapLike(at indexPath: IndexPath, completion: @escaping (Result<Void, Error>) -> Void)
    func photo(at indexPath: IndexPath) -> Photo
}

final class ImagesListViewPresenter: ImagesListViewPresenterProtocol {
    private weak var view: ImagesListViewControllerProtocol?
    private let imagesListService: ImagesListServiceProtocol
    
    private(set) var photos: [Photo] = []
    private var observer: NSObjectProtocol?
    
    init(view: ImagesListViewControllerProtocol, imagesListService: ImagesListServiceProtocol) {
        self.view = view
        self.imagesListService = imagesListService
    }
    
    func viewDidLoad() {
        setupObserver()
        loadInitialPhotos()
    }
    
    private func setupObserver() {
        observer = NotificationCenter.default.addObserver(
            forName: ImagesListService.didChangeNotification,
            object: nil,
            queue: .main
        ) { [weak self] _ in
            self?.updateTableViewAnimated()
        }
    }
    
    private func loadInitialPhotos(){
        if photos.isEmpty {
            imagesListService.fetchPhotosNextPage()
        }
    }
    
    func updateTableViewAnimated() {
        let oldCount = photos.count
        let newPhotos = imagesListService.photos
        
        let uniqueNewPhotos = newPhotos.filter { newPhoto in
            !photos.contains(where: { $0.id == newPhoto.id })
        }
        
        guard !uniqueNewPhotos.isEmpty else { return }
        
        photos.append(contentsOf: uniqueNewPhotos)
        view?.insertRows(from: oldCount, to: photos.count)
    }
    
    func willDisplayCell(at indexPath: IndexPath) {
        if indexPath.row == photos.count - 1 {
            imagesListService.fetchPhotosNextPage()
        }
    }
    
    func didTapLike(at indexPath: IndexPath, completion: @escaping (Result<Void, Error>) -> Void) {
        guard indexPath.row < photos.count else { return }
        let photo = photos[indexPath.row]
        
        imagesListService.changeLike(photoId: photo.id, isLike: !photo.isLiked) { [weak self] result in
            DispatchQueue.main.async {
                switch result {
                case .success:
                    self?.photos = self?.imagesListService.photos ?? []
                    completion(.success(()))
                case .failure(let error):
                    completion(.failure(error))
                }
            }
        }
    }
    
    func photo(at indexPath: IndexPath) -> Photo {
        return photos[indexPath.row]
    }
}
