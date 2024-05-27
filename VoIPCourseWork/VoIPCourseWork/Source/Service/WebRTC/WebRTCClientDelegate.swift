//
//  WebRTCClientDelegate.swift
//  VoIPCourseWork
//
//  Created by Полина Рыфтина on 27.05.2024.
//

import Foundation
import WebRTC

protocol WebRTCClientDelegate: AnyObject {
    func webRTCClient(
        _ client: WebRTCClient,
        didDiscoverLocalCandidate candidate: RTCIceCandidate
    )
    func webRTCClient(
        _ client: WebRTCClient,
        didChangeConnectionState state: RTCIceConnectionState
    )
    func webRTCClient(
        _ client: WebRTCClient, 
        didReceiveData data: Data
    )
}
