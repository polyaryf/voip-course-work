//
//  ViewController.swift
//  VoIPCourseWork
//
//  Created by Полина Рыфтина on 27.05.2024.
//

import UIKit
import AVFoundation
import WebRTC

final class MainViewController: UIViewController {
    
    // MARK: UI-components

    private let signalingStatusLabel = UILabel.label(with: "Signaling cтатус :")
    private let localSDPLabel = UILabel.label(with: "Статус local SDP:")
    private let localCandidatesLabel = UILabel.label(with: "Статус local candidates:")
    private let remoteSDPLabel = UILabel.label(with: "Статус remote SDP:")
    private let remoteCandidatesLabel = UILabel.label(with: "Статус remote candidates:")
    private let webRTCStatusLabel = UILabel.label(with: "Статус WEbRTC:")
    
    private lazy var labelsStack = UIStackView(arrangedSubviews: [
        signalingStatusLabel,
        localSDPLabel,
        localCandidatesLabel,
        remoteSDPLabel,
        remoteCandidatesLabel,
        webRTCStatusLabel
    ])
    
    private let loadspeakerButton = UIButton(type: .system)
    private let micButton = UIButton(type: .system)
    private let sendDataButton = UIButton(type: .system)
    private let cameraButton = UIButton(type: .system)
    private let sendOfferButton = UIButton(type: .roundedRect)
    private let sendAnswerButton = UIButton(type: .roundedRect)
    
    // MARK: Computed Properties
    
    private var signalingConnected: Bool = false {
        didSet {
            DispatchQueue.main.async {
                if self.signalingConnected {
                    self.signalingStatusLabel.text = "Signaling cтатус: Подключен"
                    self.signalingStatusLabel.textColor = UIColor.green
                }
                else {
                    self.signalingStatusLabel.text = "Signaling cтатус: Не подключен"
                    self.signalingStatusLabel.textColor = UIColor.red
                }
            }
        }
    }
    
    private var hasLocalSdp: Bool = false {
        didSet {
            DispatchQueue.main.async {
                self.localSDPLabel.text = self.hasLocalSdp ? "Статус local SDP: ✅" : "Статус local SDP: ❌"
            }
        }
    }
    
    private var localCandidateCount: Int = 0 {
        didSet {
            DispatchQueue.main.async {
                self.localCandidatesLabel.text = "Статус local candidates: \(self.localCandidateCount)"
            }
        }
    }
    
    private var hasRemoteSdp: Bool = false {
        didSet {
            DispatchQueue.main.async {
                self.remoteSDPLabel.text = self.hasRemoteSdp ? "Статус remote SDP: ✅" : "Статус remote SDP: ❌"
            }
        }
    }
    
    private var remoteCandidateCount: Int = 0 {
        didSet {
            DispatchQueue.main.async {
                self.remoteCandidatesLabel.text = "Статус remote candidates: \(self.remoteCandidateCount)"
            }
        }
    }
    
    private var speakerOn: Bool = false {
        didSet {
            let title = "Loadspeaker: \(self.speakerOn ? "On" : "Off" )"
            self.loadspeakerButton.setTitle(title, for: .normal)
        }
    }
    
    private var mute: Bool = false {
        didSet {
            let title = "Microphone is mute: \(self.mute ? "on" : "off")"
            self.micButton.setTitle(title, for: .normal)
        }
    }
    
    // MARK: Dependencies

    private let signalClient: SignalingClient
    private let webRTCClient: WebRTCClient
    private lazy var videoViewController = VideoViewController(webRTCClient: self.webRTCClient)
    
    // MARK: Init
    
    init(
        signalClient: SignalingClient,
        webRTCClient: WebRTCClient
    ) {
        self.signalClient = signalClient
        self.webRTCClient = webRTCClient
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: Life Cycle

    override func viewDidLoad() {
        super.viewDidLoad()
        
        configureNavBar()
        configureLabels()
        configureButtons()
        configure()
    }
    
    // MARK: Configuration
    
    private func configureNavBar() {
        self.navigationItem.title = "VoIP course work"
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(
            image: UIImage(named: "arrowshape.backward"),
            style: .plain,
            target: nil,
            action: #selector(leftBarButtonWasTapped)
        )
    }
    
    @objc private func leftBarButtonWasTapped() {
        self.navigationController?.popViewController(animated: true)
    }
    
    private func configure() {
        view.backgroundColor = .white
        self.signalingConnected = false
        self.hasLocalSdp = false
        self.hasRemoteSdp = false
        self.localCandidateCount = 0
        self.remoteCandidateCount = 0
        self.speakerOn = false
        self.mute = false
        self.webRTCStatusLabel.text = "Статус WEbRTC: New"
        
        self.webRTCClient.delegate = self
        self.signalClient.delegate = self
        self.signalClient.connect()
    }
    
    private func configureLabels() {
        view.addSubview(labelsStack)
        labelsStack.axis = .vertical
        labelsStack.alignment = .leading
        labelsStack.spacing = 10
        labelsStack.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            labelsStack.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 10),
            labelsStack.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -10),
            labelsStack.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 10)
        ])
    }
    
    private func configureButtons() {
        let controlAudioButonnsStack = UIStackView(arrangedSubviews: [
            loadspeakerButton, micButton
        ])
        controlAudioButonnsStack.axis = .vertical
        controlAudioButonnsStack.spacing = 8
        controlAudioButonnsStack.alignment = .leading
        let sendButtonsStack = UIStackView(arrangedSubviews: [
            sendDataButton, cameraButton
        ])
        sendButtonsStack.axis = .vertical
        sendButtonsStack.spacing = 8
        sendButtonsStack.alignment = .trailing
        
        let hstach = UIStackView(arrangedSubviews: [
            controlAudioButonnsStack, sendButtonsStack
        ])
        hstach.axis = .horizontal
        hstach.spacing = 10
        hstach.alignment = .fill
        let buttonsStack = UIStackView(arrangedSubviews: [
            sendOfferButton, sendAnswerButton, hstach
        ])
        buttonsStack.axis = .vertical
        buttonsStack.spacing = 8
        buttonsStack.alignment = .fill
        buttonsStack.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(buttonsStack)
        NSLayoutConstraint.activate([
            buttonsStack.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 10),
            buttonsStack.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -10),
            buttonsStack.topAnchor.constraint(equalTo: labelsStack.bottomAnchor, constant: 50)
        ])
        sendDataButton.setTitle("Send Data", for: .normal)
        sendOfferButton.setTitle("Send Offer", for: .normal)
        sendAnswerButton.setTitle("Send Answer", for: .normal)
        cameraButton.setTitle("Turn on video chatting", for: .normal)
        
        sendOfferButton.addTarget(self, action: #selector(sendOfferButtonWasTapped), for: .touchUpInside)
        sendAnswerButton.addTarget(self, action: #selector(sendAnswerButtonWasTapped), for: .touchUpInside)
        micButton.addTarget(self, action: #selector(micButtonWasTapped), for: .touchUpInside)
        loadspeakerButton.addTarget(self, action: #selector(loadspeakerButtonWasTapped), for: .touchUpInside)
        sendDataButton.addTarget(self, action: #selector(sendDataButtonWasTapped), for: .touchUpInside)
        cameraButton.addTarget(self, action: #selector(cameraButtonWasTapped), for: .touchUpInside)
    }
    
    @objc func loadspeakerButtonWasTapped() {
        if self.speakerOn {
            self.webRTCClient.speakerOff()
        }
        else {
            self.webRTCClient.speakerOn()
        }
        self.speakerOn = !self.speakerOn
    }
    
    @objc func micButtonWasTapped() {
        self.mute = !self.mute
        if self.mute {
            self.webRTCClient.muteAudio()
        }
        else {
            self.webRTCClient.unmuteAudio()
        }
    }
    
    @objc func sendDataButtonWasTapped() {
        let alert = UIAlertController(title: "Send a message to the other peer",
                                      message: "This will be transferred over WebRTC data channel",
                                      preferredStyle: .alert)
        alert.addTextField { (textField) in
            textField.placeholder = "Message to send"
        }
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        alert.addAction(UIAlertAction(title: "Send", style: .default, handler: { [weak self, unowned alert] _ in
            guard let dataToSend = alert.textFields?.first?.text?.data(using: .utf8) else {
                return
            }
            self?.webRTCClient.sendData(dataToSend)
        }))
        self.present(alert, animated: true, completion: nil)
    }
    
    @objc func cameraButtonWasTapped() {
        DispatchQueue.main.async { [weak self] in
            guard let self else { return }
            self.navigationController?.pushViewController(videoViewController, animated: false)
        }
        
    }
    
    @objc func sendOfferButtonWasTapped() {
        self.webRTCClient.offer { (sdp) in
            self.hasLocalSdp = true
            self.signalClient.send(sdp: sdp)
        }
    }
    
    @objc func sendAnswerButtonWasTapped() {
        self.webRTCClient.answer { (localSdp) in
            self.hasLocalSdp = true
            self.signalClient.send(sdp: localSdp)
        }
    }
}

// MARK: - SignalClientDelegate

extension MainViewController: SignalClientDelegate {
    func signalClientDidConnect(_ signalClient: SignalingClient) {
        self.signalingConnected = true
    }
    
    func signalClientDidDisconnect(_ signalClient: SignalingClient) {
        self.signalingConnected = false
    }
    
    func signalClient(_ signalClient: SignalingClient, didReceiveRemoteSdp sdp: RTCSessionDescription) {
        print("Received remote sdp")
        self.webRTCClient.set(remoteSdp: sdp) { (error) in
            self.hasRemoteSdp = true
        }
    }
    
    func signalClient(_ signalClient: SignalingClient, didReceiveCandidate candidate: RTCIceCandidate) {
        self.webRTCClient.set(remoteCandidate: candidate) { error in
            print("Received remote candidate")
            self.remoteCandidateCount += 1
        }
    }
}

// MARK: - WebRTCClientDelegate

extension MainViewController: WebRTCClientDelegate {
    
    func webRTCClient(_ client: WebRTCClient, didDiscoverLocalCandidate candidate: RTCIceCandidate) {
        print("discovered local candidate")
        self.localCandidateCount += 1
        self.signalClient.send(candidate: candidate)
    }
    
    func webRTCClient(_ client: WebRTCClient, didChangeConnectionState state: RTCIceConnectionState) {
        let textColor: UIColor
        switch state {
        case .connected, .completed:
            textColor = .green
        case .disconnected:
            textColor = .orange
        case .failed, .closed:
            textColor = .red
        case .new, .checking, .count:
            textColor = .black
        @unknown default:
            textColor = .black
        }
        
        DispatchQueue.main.async {
            self.webRTCStatusLabel.text = state.description.capitalized
            self.webRTCStatusLabel.textColor = textColor
        }
    }
    
    func webRTCClient(_ client: WebRTCClient, didReceiveData data: Data) {
        DispatchQueue.main.async {
            let message = String(data: data, encoding: .utf8) ?? "(Binary: \(data.count) bytes)"
            let alert = UIAlertController(title: "Message from WebRTC", message: message, preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .cancel, handler: nil))
            self.present(alert, animated: true, completion: nil)
        }
    }
}
