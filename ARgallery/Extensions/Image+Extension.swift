//
//  Image+Extension.swift
//  ARgallery
//
//  Created by Michal Šimík on 24.02.2022.
//

import SwiftUI
import UIKit

extension URLCache {
    static let imageCache = URLCache(memoryCapacity: 512*1000*1000, diskCapacity: 10*1000*1000*1000)
}
