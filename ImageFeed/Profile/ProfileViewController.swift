//
//  Untitled.swift
//  ImageFeed
//
//  Created by Владислав on 17.07.2025.
//

import UIKit
import Kingfisher

protocol ProfileViewControllerProtocol: AnyObject {
    func configureViews()
    func updateProfileDetails(profile: Profile)
    func showDefaultProfile()
    func setAvatar(url: URL?)
    func showLogoutConfiguration()
}

final class ProfileViewController: UIViewController, ProfileViewControllerProtocol {
    
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
        button.accessibilityIdentifier = "logout button"
        return button
    }()
    
    private let presenter: ProfileViewPresenterProtocol

    let profileLogoutService = ProfileLogoutService.shared
    
    init(presenter: ProfileViewPresenterProtocol) {
        self.presenter = presenter
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        presenter.view = self
        presenter.viewDidLoad()
        presenter.setupObservers()
    }
    
    @objc private func didTapLogoutButton() {
        presenter.didTapLogout()
    }
    
    func configureViews() {
        view.backgroundColor = UIColor(resource: .ypBlackIOS)
        setupUI()
        configureAppearance()
    }
    
    func showDefaultProfile() {
        nameLabel.text = "Имя Фамилия"
        loginNameLabel.text = "@username"
        descriptionLabel.text = nil
    }
    
    func updateProfileDetails(profile: Profile) {
        nameLabel.text = profile.name
        loginNameLabel.text = profile.loginName
        descriptionLabel.text = profile.bio
    }
    
    func setAvatar(url: URL?) {
        profilePhotoImageView.kf.cancelDownloadTask()
        guard let url = url else {
            profilePhotoImageView.image = UIImage(resource: .avatarPlaceholder)
            return
        }
        
        let processor = RoundCornerImageProcessor(cornerRadius: 61)
        profilePhotoImageView.kf.setImage(
            with: url,
            placeholder: UIImage(named: "avatar_placeholder"),
            options: [
                .processor(processor),
                .transition(.fade(0.3)),
                .cacheOriginalImage,
                .keepCurrentImageWhileLoading
            ]
        )
    }
    
    func showLogoutConfiguration() {
        let alert = UIAlertController(
            title: "Пока, пока:(",
            message: "Уже посмотрел все картинки?",
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
    
    private func configureAppearance() {
        if #available(iOS 15.0, *) {
            let appearance = UITabBarAppearance()
            appearance.configureWithOpaqueBackground()
            appearance.backgroundColor = UIColor(resource: .ypBlackIOS)
            tabBarController?.tabBar.standardAppearance = appearance
            tabBarController?.tabBar.scrollEdgeAppearance = appearance
        }
    }
    
    private func setupUI() {
        view.backgroundColor = .ypBlackIOS
        [profilePhotoImageView, nameLabel, loginNameLabel, descriptionLabel, logoutButton].forEach {
            view.addSubview($0)
        }
        setupConstraints()
    }
    
    private func setupConstraints() {
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
}

