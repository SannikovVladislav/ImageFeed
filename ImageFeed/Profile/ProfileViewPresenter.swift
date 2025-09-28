//
//  ProfileViewPresenter.swift
//  ImageFeed
//
//  Created by Владислав on 25.09.2025.
//

import Foundation

protocol ProfileViewPresenterProtocol: AnyObject {
    var view: ProfileViewControllerProtocol? { get set }
    func viewDidLoad()
    func setupObservers()
    func confirmLogout()
    func didTapLogout()
    func updateProfile()
    func updateAvatar()
}

final class ProfileViewPresenter: ProfileViewPresenterProtocol {
    weak var view: ProfileViewControllerProtocol?
    private let profileService: ProfileServiceProtocol
    private let profileImageService: ProfileImageServiceProtocol
    private let profileLogoutService: ProfileLogoutServiceProtocol
    
    private var profileImageServiceObserver: NSObjectProtocol?
    
    init(profileService: ProfileServiceProtocol,
         profileImageService: ProfileImageServiceProtocol,
         profileLogoutService: ProfileLogoutServiceProtocol) {
        self.profileService = profileService
        self.profileImageService = profileImageService
        self.profileLogoutService = profileLogoutService
    }
    
    func viewDidLoad() {
        view?.configureViews()
        updateProfile()
    }
    
    func setupObservers() {
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
    
    func confirmLogout() {
        profileLogoutService.logout()
    }
    
    func didTapLogout() {
        view?.showLogoutConfiguration()
    }
    
    func updateProfile() {
        guard let profile = profileService.profile else {
            view?.showDefaultProfile()
            return
        }
        view?.updateProfileDetails(profile: profile)
        updateAvatar()
    }
    
    func updateAvatar() {
        guard let urlString = profileImageService.avatarURL,
              let url = URL(string: urlString) else {
            view?.setAvatar(url: nil)
            return
        }
        view?.setAvatar(url: url)
    }
}

