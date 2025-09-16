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
    @IBOutlet weak var gradientView: UIView!
    
    private let gradientLayer = CAGradientLayer()
    
    override func prepareForReuse() {
        super.prepareForReuse()
        cellImageView.kf.cancelDownloadTask()
        cellImageView.image = nil
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
        setupGradient()
    }
    
    func setLikeButtonImage(isLiked: Bool) {
        let imageResource: ImageResource = isLiked ? .active : .noActive
        likeButton.setImage(UIImage(resource: imageResource), for: .normal)
    }
    
    func setupGradient() {
        guard gradientLayer.superlayer == nil else { return }
        let darkColor = UIColor(red: 26/255, green: 27/255, blue: 34/255, alpha: 1.0)
        
        gradientLayer.colors = [
            darkColor.withAlphaComponent(0.6).cgColor,
            darkColor.withAlphaComponent(0.0).cgColor
        ]        
        gradientLayer.startPoint = CGPoint(x: 0.5, y: 1.0)
        gradientLayer.endPoint = CGPoint(x: 0.5, y: 0.0)
        gradientLayer.locations = [0, 1]
        gradientView.layer.insertSublayer(gradientLayer, at: 0)
    }
}
