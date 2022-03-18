//
//  Image+Extension.swift
//  ARgallery
//
//  Created by Michal Šimík on 24.02.2022.
//

import SwiftUI

extension URLCache {
    static let imageCache = URLCache(memoryCapacity: 512*1000*1000, diskCapacity: 10*1000*1000*1000)
}

extension UIImage {
    func crop(toRect rect: CGRect) -> UIImage? {
        guard let imageRef: CGImage = self.cgImage?.cropping(to: rect) else {
            return nil
        }
        return UIImage(cgImage: imageRef)
    }
}
