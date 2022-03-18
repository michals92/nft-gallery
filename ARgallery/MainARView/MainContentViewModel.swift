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
    @Published var address = UserDefaults.standard.string(forKey: "address")  ?? ""
    @Published var tempAddress = UserDefaults.standard.string(forKey: "address")  ?? ""

    @Published var takeSnapshot = false
    @Published var imageToShare: UIImage?

    func getCollectibles() {
        let moralisService = MoralisCollectiblesService(apiAdapter: MoralisApiAdapter())

        moralisService.collectibles(address, chain: "eth", format: "decimal") { result in
            switch result {
            case .success(let collectibles):
                DispatchQueue.main.async {
                    self.collectibles = collectibles.result.filter({ collectible in
                        let dict = collectible.metadata?.convertToDictionary()
                        guard let image = dict?["image"] as? String else {
                            return false
                        }
                        return collectible.name != nil && image.hasSuffix(".png")
                    })
                }
            case .failure(let error):
                print(error)
            }
        }
    }

    func saveAddress() {
        address = tempAddress
        UserDefaults.standard.set(address, forKey: "address")
        getCollectibles()
    }
}
