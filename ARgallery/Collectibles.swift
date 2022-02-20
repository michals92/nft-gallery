//
//  Collectibles.swift
//  ModelPicker
//
//  Created by Michal Šimík on 10.02.2022.
//

import Foundation

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

    func getCollectibleURL() -> URL? {
        let dict = metadata?.convertToDictionary()
        let urlString = dict?["image"] as? String
        let urlStringWithoutIpfs = urlString?.replacingOccurrences(of: "ipfs://", with: "https://cloudflare-ipfs.com/ipfs/")
        return URL(string: urlStringWithoutIpfs ?? "")
    }
}
