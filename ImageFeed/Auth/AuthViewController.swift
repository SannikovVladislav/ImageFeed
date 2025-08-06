//
//  AuthViewController.swift
//  ImageFeed
//
//  Created by Владислав on 06.08.2025.
//
import UIKit

final class AuthViewController: UIViewController {
    private let showWebViewSegueIdentifier = "ShowWebView"

    override func viewDidLoad() {
        super.viewDidLoad()
        
        configureBackButton()
    }
    
    private func configureBackButton() {
        navigationController?.navigationBar.backIndicatorImage = UIImage(named: "nav_back_button")
        navigationController?.navigationBar.backIndicatorTransitionMaskImage = UIImage(named: "nav_back_button")
        navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)
        navigationItem.backBarButtonItem?.tintColor = UIColor(named: "YP Black (iOS)")
    }
    
    @IBAction func loginButtonTapped(_ sender: UIButton) {
    }
    
    
    
}
