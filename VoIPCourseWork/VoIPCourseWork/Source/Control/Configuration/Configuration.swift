//
//  Configuration.swift
//  VoIPCourseWork
//
//  Created by Полина Рыфтина on 27.05.2024.
//

import Foundation

// Установите IP-адрес машины, на которой будет запущен сигнальный сервер. Не используйте `localhost` или `127.0.0.1`.
// `192.168.0``- мой IP адрес
fileprivate let defaultSignalingServerUrl = URL(string: "ws://192.168.0.101:8080")!

// Для учебного проекта используются публичные stun сервера Google. Для продакшн решения необходимо деплоить свои собственные `stun/turn` сервера.
fileprivate let defaultIceServers = [
    "stun:stun.l.google.com:19302",
    "stun:stun1.l.google.com:19302",
    "stun:stun2.l.google.com:19302",
    "stun:stun3.l.google.com:19302",
    "stun:stun4.l.google.com:19302"
]

struct Config {
    let signalingServerUrl: URL
    let webRTCIceServers: [String]
    
    static let `default` = Config(
        signalingServerUrl: defaultSignalingServerUrl,
        webRTCIceServers: defaultIceServers
    )
}

