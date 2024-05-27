//
//  SceneDelegate.swift
//  VoIPCourseWork
//
//  Created by Полина Рыфтина on 27.05.2024.
//

import UIKit

class SceneDelegate: UIResponder, UIWindowSceneDelegate {
    
    var window: UIWindow?
    private let config = Config.default

    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        guard let scene = (scene as? UIWindowScene) else { return }
        window = UIWindow(windowScene: scene)
        window?.rootViewController = self.buildMainViewController()
        window?.makeKeyAndVisible()
    }
    
    private func buildMainViewController() -> UIViewController {
        let webRTCClient = WebRTCClient(iceServers: self.config.webRTCIceServers)
        let signalClient = self.buildSignalingClient()
        let mainViewController = MainViewController(signalClient: signalClient, webRTCClient: webRTCClient)
        signalClient.delegate = mainViewController
        webRTCClient.delegate = mainViewController
        let navViewController = UINavigationController(rootViewController: mainViewController)
        navViewController.navigationBar.prefersLargeTitles = true
        return navViewController
    }
    
    private func buildSignalingClient() -> SignalingClient {
        
        // iOS 13 has native websocket support. For iOS 12 or lower we will use 3rd party library.
        let webSocketProvider: WebSocketProvider
        
        if #available(iOS 13.0, *) {
            webSocketProvider = NativeWebSocket(url: self.config.signalingServerUrl)
        } else {
            webSocketProvider = StarscreamWebSocket(url: self.config.signalingServerUrl)
        }
        
        return SignalingClient(webSocket: webSocketProvider)
    }
}
