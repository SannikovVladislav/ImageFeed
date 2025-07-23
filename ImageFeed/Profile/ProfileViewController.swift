//
//  Untitled.swift
//  ImageFeed
//
//  Created by Владислав on 17.07.2025.
//

import UIKit

final class ProfileViewController: UIViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let userPhoto = UIImageView()
        userPhoto.image = UIImage(named: "Profile Photo")
        userPhoto.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(userPhoto)
        
        NSLayoutConstraint.activate([
            userPhoto.widthAnchor.constraint(equalToConstant: 70),
            userPhoto.heightAnchor.constraint(equalToConstant: 70),
            userPhoto.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 16),
            userPhoto.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 32)
        ])
        
        let nameLabel = UILabel()
        nameLabel.text = "Екатерина Новикова"
        nameLabel.font = .systemFont(ofSize: 23, weight: .bold)
        nameLabel.textColor = UIColor(named: "YP White (iOS)")
        nameLabel.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(nameLabel)
        
        NSLayoutConstraint.activate([
            nameLabel.leadingAnchor.constraint(equalTo: userPhoto.leadingAnchor),
            nameLabel.topAnchor.constraint(equalTo: userPhoto.bottomAnchor, constant: 8)
        ])
        
        let userLabel = UILabel()
        userLabel.text = "@ekaterina_nov"
        userLabel.font = .systemFont(ofSize: 13, weight: .regular)
        userLabel.textColor = UIColor(named: "YP Gray (iOS)")
        userLabel.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(userLabel)
        
        NSLayoutConstraint.activate([
            userLabel.leadingAnchor.constraint(equalTo: nameLabel.leadingAnchor),
            userLabel.topAnchor.constraint(equalTo: nameLabel.bottomAnchor, constant: 8)
        ])
        
        let descriptionLabel = UILabel()
        descriptionLabel.text = "Hello, world!"
        descriptionLabel.font = .systemFont(ofSize: 13, weight: .regular)
        descriptionLabel.textColor = UIColor(named: "YP White (iOS)")
        descriptionLabel.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(descriptionLabel)
        
        NSLayoutConstraint.activate([
            descriptionLabel.leadingAnchor.constraint(equalTo: nameLabel.leadingAnchor),
            descriptionLabel.topAnchor.constraint(equalTo: userLabel.bottomAnchor, constant: 8)
        ])
        
        let exitButton = UIButton.systemButton(
            with: UIImage(named: "Exit Button")!,
            target: self,
            action: #selector(method))
        exitButton.tintColor = UIColor(named: "YP Red (iOS)")
        exitButton.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(exitButton)
        
        NSLayoutConstraint.activate([
            exitButton.widthAnchor.constraint(equalToConstant: 44),
            exitButton.heightAnchor.constraint(equalToConstant: 44),
            exitButton.rightAnchor.constraint(equalTo: view.safeAreaLayoutGuide.rightAnchor, constant: -16),
            exitButton.centerYAnchor.constraint(equalTo: userPhoto.centerYAnchor)
        ])
    }
}
