//
//  Untitled.swift
//  ImageFeed
//
//  Created by Владислав on 17.07.2025.
//

import UIKit
import Kingfisher

final class ProfileViewController: UIViewController {
    
    private lazy var profilePhotoImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(resource: .avatarPlaceholder)
        imageView.contentMode = .scaleAspectFill
        imageView.layer.cornerRadius = 35
        imageView.clipsToBounds = true
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    
    private lazy var nameLabel: UILabel = {
        let label = UILabel()
        label.textColor = .ypWhiteIOS
        label.font = UIFont.systemFont(ofSize: 23, weight: .bold)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private lazy var loginNameLabel: UILabel = {
        let label = UILabel()
        label.textColor = .ypGrayIOS
        label.font = UIFont.systemFont(ofSize: 13)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private lazy var descriptionLabel: UILabel = {
        let label = UILabel()
        label.textColor = .ypWhiteIOS
        label.font = UIFont.systemFont(ofSize: 13)
        label.numberOfLines = 0
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private lazy var logoutButton: UIButton = {
        let button = UIButton(type: .system)
        button.setImage(UIImage(resource: .exitButton), for: .normal)
        button.tintColor = .ypRedIOS
        button.addTarget(self, action: #selector(didTapLogoutButton), for: .touchUpInside)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    private let profileService = ProfileService.shared
    private let profileImageService = ProfileImageService.shared
    private var profileImageServiceObserver: NSObjectProtocol?
    let profileLogoutService = ProfileLogoutService.shared
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupObservers()
        configureAppearance()
        loadProfileData()
    }
    
    @objc func didTapLogoutButton() {
        let alert = UIAlertController(
            title: "Пока, пока!",
            message: "Уверены, что хотите выйти?",
            preferredStyle: .alert
        )
        alert.addAction(
            UIAlertAction(title: "Нет", style: .cancel)
        )
        alert.addAction(
            UIAlertAction(title: "Да", style: .destructive) { [weak self] _ in
                self?.profileLogoutService.logout()
            }
        )
        present(alert, animated: true)
    }
    
    private func setupUI() {
        view.backgroundColor = .ypBlackIOS
        [profilePhotoImageView, nameLabel, loginNameLabel, descriptionLabel, logoutButton].forEach {
            view.addSubview($0)
        }
        
        NSLayoutConstraint.activate([
            // Profile Photo
            profilePhotoImageView.widthAnchor.constraint(equalToConstant: 70),
            profilePhotoImageView.heightAnchor.constraint(equalToConstant: 70),
            profilePhotoImageView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant:32),
            profilePhotoImageView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            
            // Name Label
            nameLabel.leadingAnchor.constraint(equalTo: profilePhotoImageView.leadingAnchor),
            nameLabel.topAnchor.constraint(equalTo: profilePhotoImageView.bottomAnchor, constant: 8),
            
            //Login Name
            loginNameLabel.leadingAnchor.constraint(equalTo: profilePhotoImageView.leadingAnchor),
            loginNameLabel.topAnchor.constraint(equalTo: nameLabel.bottomAnchor, constant: 8),
            
            // Description
            descriptionLabel.leadingAnchor.constraint(equalTo: profilePhotoImageView.leadingAnchor),
            descriptionLabel.topAnchor.constraint(equalTo: loginNameLabel.bottomAnchor, constant: 8),
            
            //Logout Button
            logoutButton.widthAnchor.constraint(equalToConstant: 44),
            logoutButton.heightAnchor.constraint(equalToConstant: 44),
            logoutButton.centerYAnchor.constraint(equalTo: profilePhotoImageView.centerYAnchor),
            logoutButton.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -16)
        ])
    }
    
    private func configureView() {
        view.backgroundColor = UIColor(resource: .ypBlackIOS)
    }
    
    private func setupObservers() {
        profileImageServiceObserver = NotificationCenter.default.addObserver(
            forName: ProfileImageService.didChangeNotification,
            object: nil,
            queue: .main
        ) { [weak self] _ in
            self?.updateAvatar()
        }
    }
    
    private func configureAppearance() {
        if #available(iOS 15.0, *) {
            let appearance = UITabBarAppearance()
            appearance.configureWithOpaqueBackground()
            appearance.backgroundColor = UIColor(resource: .ypBlackIOS)
            tabBarController?.tabBar.standardAppearance = appearance
            tabBarController?.tabBar.scrollEdgeAppearance = appearance
        }
    }
    
    private func updateAvatar() {
        guard
            let profileImageURL = ProfileImageService.shared.avatarURL,
            let url = URL(string: profileImageURL)
        else {
            profilePhotoImageView.image = UIImage(resource: .avatarPlaceholder)
            return
        }
        profilePhotoImageView.kf.cancelDownloadTask()
        
        let processor = RoundCornerImageProcessor(cornerRadius: 61)
        profilePhotoImageView.kf.setImage(with: url,
                                          placeholder: UIImage(resource: .avatarPlaceholder),
                                          options: [
                                            .processor(processor),
                                            .transition(.fade(0.3)),
                                            .cacheOriginalImage,
                                            .keepCurrentImageWhileLoading
                                          ])
    }
    
    private func loadProfileData() {
        guard let profile = ProfileService.shared.profile else {
            showDefaultProfile()
            return
        }
        updateProfileDetails(profile: profile)
        ProfileImageService.shared.fetchProfileImageURL(username: profile.userName) { [weak self] result in
            switch result {
            case .success:
                self?.updateAvatar()
            case .failure(let error):
                print("Failed to load avatar: \(error)")
            }
        }
    }
    
    private func showDefaultProfile() {
        nameLabel.text = "Имя Фамилия"
        loginNameLabel.text = "@username"
        descriptionLabel.text = nil
    }
    
    private func updateProfileDetails(profile: Profile) {
        nameLabel.text = profile.name
        loginNameLabel.text = profile.loginName
        descriptionLabel.text = profile.bio
    }
}
