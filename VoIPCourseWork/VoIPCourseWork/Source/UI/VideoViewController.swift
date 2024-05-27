//
//  VideoViewController.swift
//  VoIPCourseWork
//
//  Created by Полина Рыфтина on 27.05.2024.
//

import UIKit
import WebRTC

final class VideoViewController: UIViewController {
    
    // MARK: UI-components
    private weak var localVideoView: UIView?
    
    // MARK: Dependencies
    
    private let webRTCClient: WebRTCClient
    
    // MARK: Init
    
    init(webRTCClient: WebRTCClient) {
        self.webRTCClient = webRTCClient
        
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: Life Cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
            
        configure()
        
        guard let localVideoView else { return }
        
        view.addSubview(localVideoView)
        localVideoView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            localVideoView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            localVideoView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            localVideoView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            localVideoView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor)
        ])
    }
    
    // MARK: Configuration
    
    private func configure() {
        let localRenderer = RTCMTLVideoView(frame: self.localVideoView?.frame ?? CGRect.zero)
        let remoteRenderer = RTCMTLVideoView(frame: self.view.frame)
        localRenderer.videoContentMode = .scaleAspectFill
        remoteRenderer.videoContentMode = .scaleAspectFill
        

        self.webRTCClient.startCaptureLocalVideo(renderer: localRenderer)
        self.webRTCClient.renderRemoteVideo(to: remoteRenderer)
        
        if let localVideoView = self.localVideoView {
            self.embedView(localRenderer, into: localVideoView)
        }
        self.embedView(remoteRenderer, into: self.view)
        self.view.sendSubviewToBack(remoteRenderer)
    }
    
    private func embedView(_ view: UIView, into containerView: UIView) {
        containerView.addSubview(view)
        view.translatesAutoresizingMaskIntoConstraints = false
        containerView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|[view]|",
                                                                    options: [],
                                                                    metrics: nil,
                                                                    views: ["view":view]))
        
        containerView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|[view]|",
                                                                    options: [],
                                                                    metrics: nil,
                                                                    views: ["view":view]))
        containerView.layoutIfNeeded()
    }
}
