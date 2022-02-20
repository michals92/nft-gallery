//
//  ARViewModel.swift
//  ModelPicker
//
//  Created by Michal Šimík on 09.02.2022.
//

import Foundation
import UIKit
import RealityKit

final class MainContentViewModel: ObservableObject {
    @Published var isPlacementEnabled = false
    @Published var selectedModel: Collectible?
    @Published var collectibleForPlacement: Collectible?

    @Published var hasWallet = false
    @Published var collectibles: [Collectible] = []
    @Published var address = "0x728f2548559e2aacae8b6b01fc39ff72771ff8be"

    func getCollectibles() {
        let moralisService = MoralisCollectiblesService(apiAdapter: MoralisApiAdapter())

        // TODO: use real address
        moralisService.collectibles(address, chain: "eth", format: "decimal") { result in
            switch result {
            case .success(let collectibles):
                self.collectibles = collectibles.result.filter({ collectible in
                    let dict = collectible.metadata?.convertToDictionary()
                    guard let image = dict?["image"] as? String else {
                        return false
                    }
                    return collectible.name != nil && image.hasSuffix(".png")
                })
            case .failure(let error):
                print(error)
            }
        }
    }
}
