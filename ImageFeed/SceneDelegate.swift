//
//  SceneDelegate.swift
//  ImageFeed
//
//  Created by Владислав on 14.07.2025.
//

import UIKit

class SceneDelegate: UIResponder, UIWindowSceneDelegate {
    
    var window: UIWindow?
    
    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        guard let windowScene = (scene as? UIWindowScene) else { return }
        
        let window = UIWindow(windowScene: windowScene)
        //let storyboard = UIStoryboard(name: "Main", bundle: nil)
        window.rootViewController = SplashViewController()
        self.window = window
        window.makeKeyAndVisible()
        
    }
}
