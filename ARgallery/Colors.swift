//
//  Colors.swift
//  ARgallery
//
//  Created by Michal Šimík on 27.02.2022.
//

import SwiftUI

extension UIColor {
    static let primaryBackgroundColor = UIColor(red: 0.09, green: 0.09, blue: 0.122, alpha: 1)
    static let secondaryBackgroundColor = UIColor(red: 0.118, green: 0.125, blue: 0.161, alpha: 1)

    static let separatorColor = UIColor(red: 0.231, green: 0.243, blue: 0.31, alpha: 1)

    static let primaryTextColor = UIColor(red: 0.941, green: 0.949, blue: 1, alpha: 1)
    static let secondaryTextColor = UIColor(red: 0.761, green: 0.769, blue: 0.812, alpha: 1)
    static let ternaryTextColor = UIColor(red: 0.518, green: 0.533, blue: 0.612, alpha: 1)
}

extension Color {
    init(hex: Int, opacity: Double = 1.0) {
        let red = Double((hex & 0xFF0000) >> 16) / 255.0
        let green = Double((hex & 0xFF00) >> 8) / 255.0
        let blue = Double((hex & 0xFF) >> 0) / 255.0
        self.init(.sRGB, red: red, green: green, blue: blue, opacity: opacity)
    }
}
