//
//  Untitled.swift
//  ImageFeed
//
//  Created by Владислав on 17.07.2025.
//

import UIKit
import Kingfisher

final class ProfileViewController: UIViewController {
    
    // MARK: - Private Properties
    private var profilePhotoImageView: UIImageView!
    private var nameLabel: UILabel!
    private var loginNameLabel: UILabel!
    private var descriptionLabel: UILabel!
    private var logoutButton: UIButton!
    
    private var profileImageServiceObserver: NSObjectProtocol?
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupUI()
        setupObservers()
        configureAppearance()
        loadProfileData()
        
    }
    
    // MARK: - Actions
    // TODO:
    @objc func didTapLogoutButton() {}
    
    // MARK: - Private Methods
    private func setupObservers() {
        profileImageServiceObserver = NotificationCenter.default
            .addObserver(
                forName: ProfileImageService.didChangeNotification,
                object: nil,
                queue: .main
            ) { [weak self] _ in
                guard let self = self else { return }
                self.updateAvatar()
            }
    }
    
    private func configureAppearance() {
        if #available(iOS 15.0, *) {
            let appearance = UITabBarAppearance()
            appearance.configureWithOpaqueBackground()
            appearance.backgroundColor = UIColor(named: "YP Black (iOS)")
            tabBarController?.tabBar.standardAppearance = appearance
            tabBarController?.tabBar.scrollEdgeAppearance = appearance
        }
    }
    
    private func updateAvatar() {
        guard
            let profileImageURL = ProfileImageService.shared.avatarURL,
            let url = URL(string: profileImageURL)
        else {
            // print("💅 avatar URL available, using placeholder")
            profilePhotoImageView.image = UIImage(named: "avatar_placeholder")
            return
        }
        profilePhotoImageView.kf.cancelDownloadTask()
        
        // print("💅 Loading avatar from URL: \(url.absoluteString)")
        let processor = RoundCornerImageProcessor(cornerRadius: 61)
        profilePhotoImageView.kf.setImage(with: url,
                                          placeholder: UIImage(named: "avatar_placeholder"),
                                          options: [
                                            .processor(processor),
                                            .transition(.fade(0.3)),
                                            .cacheOriginalImage,
                                            .keepCurrentImageWhileLoading
                                          ])
        //        { [weak self] result in
        //            switch result {
        //            case .success(let value):
        //                print("💅 Avatar loaded successfully: \(value.source.url?.absoluteString ?? "")")
        //            case .failure(let error):
        //                print("💅 Failed to load avatar: \(error.localizedDescription)")
        //                self?.profilePhotoImageView.image = UIImage(named: "avatar_placeholder")
        //            }
        //        }
    }
    
    //    private func updateProfile() {
    //        guard let profile = ProfileService.shared.profile else {
    //            print("Profile data is not available")
    //
    //            return
    //        }
    //        updateProfileDetails(profile: profile)
    //    }
    
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
    
    private func setupUI() {
        view.backgroundColor = .ypBlackIOS
        setupProfilePhoto()
        setupName()
        setupLoginName()
        setupDescription()
        setupLogoutButton()
        setupConstraints()
    }
    
    private func configureView() {
        view.backgroundColor = UIColor(named: "YP Black (iOS)")
    }
    
    private func setupProfilePhoto() {
        profilePhotoImageView = UIImageView()
        profilePhotoImageView.translatesAutoresizingMaskIntoConstraints = false
        profilePhotoImageView.layer.cornerRadius = 35
        view.addSubview(profilePhotoImageView)
    }
    
    private func setupName() {
        nameLabel = UILabel()
        nameLabel.font = UIFont.systemFont(ofSize: 18, weight: .bold)
        nameLabel.textColor = UIColor(named: "YP White (iOS)")
        
        nameLabel.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(nameLabel)
    }
    
    private func setupLoginName() {
        loginNameLabel = UILabel()
        loginNameLabel.font = UIFont.systemFont(ofSize: 13, weight: .regular)
        loginNameLabel.textColor = UIColor(named: "YP Gray (iOS)")
        
        loginNameLabel.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(loginNameLabel)
    }
    
    private func setupDescription() {
        descriptionLabel = UILabel()
        descriptionLabel.font = UIFont.systemFont(ofSize: 13, weight: .regular)
        descriptionLabel.textColor = UIColor(named: "YP White (iOS)")
        
        descriptionLabel.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(descriptionLabel)
    }
    
    private func setupLogoutButton() {
        guard let exitImage = UIImage(named: "Exit Button") else {
            assertionFailure("Failed to load exit image")
            return
        }
        logoutButton = UIButton.systemButton(
            with: exitImage,
            target: self,
            action: #selector (Self.didTapLogoutButton))
        logoutButton.tintColor = UIColor(named: "YP Red (iOS)")
        
        logoutButton.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(logoutButton)
    }
    
    // MARK: - Constraints
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
