//
//  MoralisService.swift
//  ModelPicker
//
//  Created by Michal Šimík on 09.02.2022.
//

import Foundation
import FTAPIKit

protocol MoralisService {
    func collectibles(completion: @escaping (Result<Collectibles, APIErrorStandard>) -> Void)
    func collectiblesCount(for address: String, completion: @escaping (Result<Int, APIErrorStandard>) -> Void)
    func setWalletAddress(_ address: String)
    var walletAddress: String? { get }
}

final class MoralisCollectiblesService: MoralisService {
    private let apiAdapter: MoralisApiAdapter

    private let walletKey = "wallet-key"

    private(set) var walletAddress: String?
    private let temporaryAddress = "0x7F6339bBF6a0B38a891C8Fb0027B30C4223Eb681"

    init(apiAdapter: MoralisApiAdapter) {
        self.apiAdapter = apiAdapter
        self.walletAddress = UserDefaults.standard.string(forKey: walletKey)
    }

    func setWalletAddress(_ address: String) {
        walletAddress = address
        UserDefaults.standard.set(address, forKey: walletKey)
    }

    func collectibles(completion: @escaping (Result<Collectibles, APIErrorStandard>) -> Void) {
        let chain = walletAddress != nil ? "eth" : "matic"
        let address = walletAddress ?? temporaryAddress
        let endpoint = MoralisNftEndpoint(chain: chain, format: "decimal", address: address)

        apiAdapter.call(response: endpoint) { result in
            switch result {
            case let .success(response):
                completion(.success(response))
            case let .failure(error):
                completion(.failure(error))
            }
        }
    }

    func collectiblesCount(for address: String, completion: @escaping (Result<Int, APIErrorStandard>) -> Void) {
        let endpoint = MoralisNftEndpoint(chain: "eth", format: "decimal", address: address)

        apiAdapter.call(response: endpoint) { result in
            switch result {
            case let .success(response):
                let collectibles = response.result.filter { collectible in
                    let dict = collectible.metadata?.convertToDictionary()
                    guard let image = dict?["image"] as? String else {
                        return false
                    }
                    return image.hasSuffix(".png") || image.hasSuffix(".jpg")
                }

                completion(.success(collectibles.count))
            case let .failure(error):
                completion(.failure(error))
            }
        }
    }
}
