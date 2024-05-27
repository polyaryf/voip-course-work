//
//  SdpType.swift
//  VoIPCourseWork
//
//  Created by Полина Рыфтина on 27.05.2024.
//

import Foundation
import WebRTC

/// This enum is a swift wrapper over `RTCSdpType` for easy encode and decode
enum SdpType: String, Codable {
    case offer, prAnswer, answer, rollback
    
    var rtcSdpType: RTCSdpType {
        switch self {
        case .offer:    return .offer
        case .answer:   return .answer
        case .prAnswer: return .prAnswer
        case .rollback: return .rollback
        }
    }
}
