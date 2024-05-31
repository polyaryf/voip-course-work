//
//  SignalClientDelegate.swift
//  VoIPCourseWork
//
//  Created by Полина Рыфтина on 27.05.2024.
//

import Foundation
import WebRTC

protocol SignalClientDelegate: AnyObject {
    func signalClientDidConnect(_ signalClient: SignalingClient)
    func signalClientDidDisconnect(_ signalClient: SignalingClient)
    func signalClient(
        _ signalClient: SignalingClient,
        didReceiveRemoteSdp sdp: RTCSessionDescription
    )
    func signalClient(
        _ signalClient: SignalingClient,
        didReceiveCandidate candidate: RTCIceCandidate
    )
}
