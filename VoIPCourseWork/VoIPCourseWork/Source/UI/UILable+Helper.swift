//
//  UILable+Helper.swift
//  VoIPCourseWork
//
//  Created by Полина Рыфтина on 27.05.2024.
//

import UIKit

extension UILabel {
    static func label(with text: String) -> UILabel {
        let label = UILabel()
        label.text = text
        label.textColor = .black
        label.font = .systemFont(ofSize: 20, weight: .medium)
        return label
    }
    
    func set(status: String) {
        self.text = (text ?? "") + " \(status)"
    }
}
