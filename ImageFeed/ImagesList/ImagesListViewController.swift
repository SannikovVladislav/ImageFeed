//
//  ViewController.swift
//  ImageFeed
//
//  Created by Владислав on 14.07.2025.
//

import UIKit

final class ImagesListViewController: UIViewController {
    
    @IBOutlet private var tableView: UITableView!
    
    private var photos: [Photo] = []
    private let showSingleImageSegueIdentifier = "ShowSingleImage"
    private let imagePlaceholder = UIImage(named: "image_placeholder")
    private let imagesListService = ImagesListService.shared
    private var observer: NSObjectProtocol?
    
    private lazy var dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .long
        formatter.timeStyle = .none
        return formatter
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupTableView()
        setupObserver()
        loadInitialPhotos()
        
        if photos.isEmpty {
            ImagesListService.shared.fetchPhotosNextPage()
        }
    }
    
    @objc private func handlePhotosUpdate() {
        updateTableViewAnimated()
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        UIStatusBarStyle.lightContent
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == showSingleImageSegueIdentifier,
           let viewController = segue.destination as? SingleImageViewController,
           let indexPath = sender as? IndexPath {
            let photo = photos[indexPath.row]
            viewController.imageURL = URL(string: photo.largeImageURL)
        }
    }
    
    private func setupTableView() {
        tableView.rowHeight = 200
        tableView.contentInset = UIEdgeInsets(top: 12, left: 0, bottom: 12, right: 0)
        print("ImagesListViewController loaded")
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
            ImagesListService.shared.fetchPhotosNextPage()
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
        
        tableView.performBatchUpdates {
            let indexPaths = (oldCount..<photos.count).map { IndexPath(row: $0, section: 0) }
            tableView.insertRows(at: indexPaths, with: .automatic)
        }
    }
    
    private func reloadVisibleCells() {
        tableView.indexPathsForVisibleRows?.forEach { indexPath in
            if let cell = tableView.cellForRow(at: indexPath) as? ImagesListCell {
                configCell(for: cell, with: photos[indexPath.row])
            }
        }
    }
}

extension ImagesListViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return photos.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: ImagesListCell.reuseIdentifier, for: indexPath)
        
        guard let imageListCell = cell as? ImagesListCell else { return UITableViewCell() }
        
        configCell(for: imageListCell, with: photos[indexPath.row])
    
        return imageListCell
    }
    private func configCell(for cell: ImagesListCell, with photo: Photo) {
        cell.configure(with: photo)
        cell.delegate = self
    }
}

extension ImagesListViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        performSegue(withIdentifier: showSingleImageSegueIdentifier, sender: indexPath)
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell,forRowAt indexPath: IndexPath) {
        if indexPath.row == photos.count - 1 {
            imagesListService.fetchPhotosNextPage()
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        let photo = photos[indexPath.row]
        let imageInsets = UIEdgeInsets(top: 4, left: 16, bottom: 4, right: 16)
        let imageViewWidth = tableView.bounds.width - imageInsets.left - imageInsets.right
        let ratio = imageViewWidth / photo.size.width
        return photo.size.height * ratio + imageInsets.top + imageInsets.bottom
    }
}

extension ImagesListViewController: ImagesListCellDelegate {
    func imageListCellDidTapLike(_ cell: ImagesListCell) {
        guard let indexPath = tableView.indexPath(for: cell) else { return }
        let photo = photos[indexPath.row]
        
        UIBlockingProgressHUD.show()
        ImagesListService.shared.changeLike(
            photoId: photo.id,
            isLike: !photo.isLiked
        ) { [weak self] result in
            guard let self else { return }
            
            DispatchQueue.main.async {
                UIBlockingProgressHUD.dismiss()
                switch result {
                case .success:
                    self.photos = self.imagesListService.photos
                    if indexPath.row < self.photos.count {
                        cell.setLikeButtonImage(isLiked: self.photos[indexPath.row].isLiked)
                    }
                    
                case .failure(let error):
                    print("Like error: \(error)")
                    cell.setLikeButtonImage(isLiked: photo.isLiked)
                    self.showLikeErrorAlert()
                }
            }
            
        }
    }
    func showLikeErrorAlert() {
        let alert = UIAlertController(
            title: "Ошибка",
            message: "Не удалось изменить лайк",
            preferredStyle: .alert
        )
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
}


