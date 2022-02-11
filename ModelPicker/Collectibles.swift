//
//  Collectibles.swift
//  ModelPicker
//
//  Created by Michal Šimík on 10.02.2022.
//

import Foundation
import RealityKit
import UIKit

struct Collectibles: Codable {
    let total: Int
    let result: [Collectible]
}

struct Collectible: Codable, Hashable {
    let tokenAddress: String
    let tokenId: String
    let name: String?
    let tokenUri: String?
    let metadata: String?

    func entity() -> String? {
        let dict = convertToDictionary(text: metadata ?? "")
        return dict?["image"] as? String
    }
}
