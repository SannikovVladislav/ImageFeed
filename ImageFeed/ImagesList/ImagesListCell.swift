//
//  Untitled.swift
//  ImageFeed
//
//  Created by Владислав on 15.07.2025.
//

import UIKit

protocol ImagesListCellDelegate: AnyObject {
    func imageListCellDidTapLike(_ cell: ImagesListCell)
}

final class ImagesListCell: UITableViewCell {
    
    weak var delegate: ImagesListCellDelegate?
    
    static let reuseIdentifier = "ImagesListCell"
    
    @IBOutlet weak var cellImageView: UIImageView!
    @IBOutlet weak var likeButton: UIButton!
    @IBOutlet weak var dateLabel: UILabel!
    
    override func prepareForReuse() {
        super.prepareForReuse()
            cellImageView.kf.cancelDownloadTask()
            cellImageView.image = nil
           // fullsizeImageView.kf.cancelDownloadTask()
        }
    
    @IBAction private func likeButtonClicked(_ sender: UIButton) {
        delegate?.imageListCellDidTapLike(self)
    }
    
    func configure(with photo: Photo) {
            cellImageView.kf.setImage(
                with: URL(string: photo.thumbImageURL),
                placeholder: UIImage(resource: .imagePlaceholder)
            )
        if let date = photo.createdAt {
                let formatter = DateFormatter()
            formatter.dateFormat = "d MMMM yyyy"
                formatter.locale = Locale(identifier: "ru_RU")
                dateLabel.text = formatter.string(from: date)
            } else {
                dateLabel.text = ""
            }
            setLikeButtonImage(isLiked: photo.isLiked)
        }
        
        func setLikeButtonImage(isLiked: Bool) {
            let imageName = isLiked ? "Active" : "No Active"
            likeButton.setImage(UIImage(named: imageName), for: .normal)
        }
}
