//
//  AuthViewController.swift
//  ImageFeed
//
//  Created by Владислав on 06.08.2025.
//
import UIKit
import ProgressHUD


protocol AuthViewControllerDelegate: AnyObject {
    func didAuthenticate(_ vc: AuthViewController)
}

final class AuthViewController: UIViewController {
    private let showWebViewSegueIdentifier = "ShowWebView"
    private let oauth2Service = OAuth2Service.shared
    private let tokenStorage = OAuth2TokenStorage()
    
    weak var delegate: AuthViewControllerDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    @IBAction private func loginButtonTapped(_ sender: UIButton) {
        showWebView()
    }
    
    private func showWebView() {
        let storyboard = UIStoryboard(name: "Main", bundle: .main)
        guard let webViewVC = storyboard.instantiateViewController(withIdentifier: "WebViewViewController") as? WebViewViewController else {
            assertionFailure("Could not instantiate WebViewViewController")
            return
        }
        
        webViewVC.delegate = self
        
        let navController = UINavigationController(rootViewController: webViewVC)
        navController.modalPresentationStyle = .fullScreen
        present(navController, animated: true)
    }
    
    private func showAuthErrorAlert() {
        let alert = UIAlertController(
            title: "Что-то пошло не так(",
            message: "Не удалось войти в систему",
            preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "ОK", style: .default, handler: nil))
        present(alert, animated: true)
    }
}

extension AuthViewController: WebViewViewControllerDelegate {
    
    func webViewViewController(_ vc: WebViewViewController, didAuthenticateWithCode code: String) {
        UIBlockingProgressHUD.show()
        
        oauth2Service.fetchOAuthToken(code: code) { [weak self] result in
            guard let self else { return }
            
            DispatchQueue.main.async {
                UIBlockingProgressHUD.dismiss()
                
                switch result {
                case .success(let token):
                    self.tokenStorage.token = token
                    self.delegate?.didAuthenticate(self)
                    print("Successfully fetched token: \(token)")
                    
                case .failure(let error):
                    print("❌Failed to fetch token: \(error)")
                    vc.dismiss(animated: true) {
                        self.showAuthErrorAlert()
                    }
                }
            }
        }
    }
    
    func webViewViewControllerDidCancel(_ vc: WebViewViewController) {
        vc.dismiss(animated: true)
    }
}
