//
//  SingleImageViewController.swift
//  ImageFeed
//
//  Created by Владислав on 19.07.2025.
//

import UIKit

final class SingleImageViewController: UIViewController {
    
    @IBOutlet private var singleImageView: UIImageView!
    @IBOutlet private var scrollView: UIScrollView!
    
    @IBAction private func didTapBackButton(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    @IBAction func didTapShareButton(_ sender: UIButton) {
        guard let image else { return }
        let share = UIActivityViewController(
            activityItems: [image],
            applicationActivities: nil
        )
        present(share, animated: true, completion: nil)
    }
    
    var image: UIImage? {
        didSet {
            guard isViewLoaded, let image else { return }
            singleImageView.image = image
            singleImageView.frame.size = image.size
            rescaleAndCenterImageInScrollView(image: image)
        }
    }
    
    var imageURL: URL?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        scrollView.minimumZoomScale = 0.1
        scrollView.maximumZoomScale = 1.25
        
        if let image = image {
                    singleImageView.image = image
                    singleImageView.frame.size = image.size
                    scrollView.contentSize = image.size
                    rescaleAndCenterImageInScrollView(image: image)
                } else {
                    loadImage()
                }
    }
    
    
    private func loadImage() {
        guard let imageURL else { return }
        
        UIBlockingProgressHUD.show()
        singleImageView.kf.setImage(with: imageURL) { [weak self] result in
            UIBlockingProgressHUD.dismiss()
            
            guard let self else { return }
            switch result {
            case .success(let imageResult):
                self.singleImageView.image = imageResult.image
                self.singleImageView.frame.size = imageResult.image.size
                self.scrollView.contentSize = imageResult.image.size
                self.rescaleAndCenterImageInScrollView(image: imageResult.image)
            case .failure:
                self.showError()
            }
        }
    }
    
    private func showError() {
            let alert = UIAlertController(
                title: "Ошибка",
                message: "Что-то пошло не так. Попробовать ещё раз?",
                preferredStyle: .alert
            )
            
            alert.addAction(UIAlertAction(title: "Не надо", style: .default))
            alert.addAction(UIAlertAction(title: "Повторить", style: .default) { [weak self] _ in
                self?.loadImage()
            })
            
            present(alert, animated: true)
        }
    
    private func rescaleAndCenterImageInScrollView(image: UIImage) {
        let minZoomScale = scrollView.minimumZoomScale
        let maxZoomScale = scrollView.maximumZoomScale
        
       // view.layoutIfNeeded()
        
        let visibleRectSize = scrollView.bounds.size
        let imageSize = image.size
        
        let hScale = visibleRectSize.width / imageSize.width
        let vScale = visibleRectSize.height / imageSize.height
        let scale = min(maxZoomScale, max(minZoomScale, max(hScale, vScale)))
        
        scrollView.setZoomScale(scale, animated: false)
        //scrollView.contentSize = image.size
        scrollView.layoutIfNeeded()
        
        updateContentInset()
    }
    
    private func updateContentInset() {
        let imageViewSize = singleImageView.frame.size
        let scrollViewSize = scrollView.bounds.size
        
        let verticalInset = max(0, (scrollViewSize.height - imageViewSize.height) / 2)
        let horizontalInset = max(0, (scrollViewSize.width - imageViewSize.width) / 2)
        
        scrollView.contentInset = UIEdgeInsets(
            top: verticalInset,
            left: horizontalInset,
            bottom: verticalInset,
            right: horizontalInset
        )
    }
}

extension SingleImageViewController: UIScrollViewDelegate {
    func viewForZooming(in scrollView: UIScrollView) -> UIView? { singleImageView }
}
