//
//  ARViewModel.swift
//  ModelPicker
//
//  Created by Michal Šimík on 09.02.2022.
//

import Foundation
import RealityKit
import UIKit

final class MainContentViewModel: ObservableObject {
    @Published var isPlacementEnabled = false
    @Published var selectedModel: Collectible?
    @Published var collectibleForPlacement: Collectible?

    @Published var hasWallet = false
    @Published var collectibles: [Collectible] = []
    @Published var address: String
    @Published var tempAddress: String

    @Published var takeSnapshot = false
    @Published var imageToShare: UIImage?

    let moralisService: MoralisService

    init() {
        moralisService = MoralisCollectiblesService(apiAdapter: MoralisApiAdapter())
        address = moralisService.walletAddress ?? ""
        tempAddress = moralisService.walletAddress ?? ""
    }

    func getCollectibles() {

        moralisService.collectibles() { result in
            switch result {
            case let .success(collectibles):
                DispatchQueue.main.async {
                    self.collectibles = collectibles.result.filter { collectible in
                        let dict = collectible.metadata?.convertToDictionary()
                        guard let image = dict?["image"] as? String else {
                            return false
                        }
                        return image.hasSuffix(".png") || image.hasSuffix(".jpg")
                    }
                }
            case let .failure(error):
                print(error)
            }
        }
    }

    func saveAddress() {
        address = tempAddress
        moralisService.setWalletAddress(address)
        getCollectibles()
    }
}
