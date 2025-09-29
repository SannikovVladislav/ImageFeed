//
//  TabBarController.swift
//  ImageFeed
//
//  Created by Владислав on 30.08.2025.
//

import UIKit

final class TabBarController: UITabBarController {
    override func awakeFromNib() {
        super.awakeFromNib()
        let storyboard = UIStoryboard(name: "Main", bundle: .main)
        
        let imagesListViewController = storyboard.instantiateViewController(
            withIdentifier: "ImagesListViewController"
        )
        
        let profileService = ProfileService.shared
        let profileImageService = ProfileImageService.shared
        let profileLogoutService = ProfileLogoutService.shared
        
        let presenter = ProfileViewPresenter(
            profileService: profileService,
            profileImageService: profileImageService,
            profileLogoutService: profileLogoutService
        )
        let profileViewController = ProfileViewController(presenter: presenter)
        profileViewController.tabBarItem = UITabBarItem(
            title: "",
            image: UIImage(named:"tab_profile_active"),
            selectedImage: nil
        )
        self.viewControllers = [imagesListViewController, profileViewController]
    }
}
