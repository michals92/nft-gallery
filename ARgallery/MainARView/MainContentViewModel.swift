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
    let router: RouterProtocol

    init(router: RouterProtocol) {
        self.router = router
        moralisService = MoralisCollectiblesService(apiAdapter: MoralisApiAdapter())
        address = moralisService.walletAddress ?? ""
        tempAddress = moralisService.walletAddress ?? ""
    }

    func getCollectibles() {
        if moralisService.walletAddress == nil {
            // TODO: add assets for collectibles
            self.collectibles = [Collectible(tokenAddress: "address", tokenId: "tokenId", name: "test", tokenUri: "uri", metadata: "{                                       \"image\": \"https://d32-a.sdn.cz/d_32/c_static_QN_Q/FxUBTO/media/img/zodiac/7.png\"}")]
        } else {
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
    }

    func saveAddress() {
        address = tempAddress
        moralisService.setWalletAddress(address)
        getCollectibles()
    }
}
