//
//  ARViewModel.swift
//  ModelPicker
//
//  Created by Michal Šimík on 09.02.2022.
//

import Foundation
import UIKit
import ARKit

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
                    let dict = convertToDictionary(text: collectible.metadata ?? "")

                    print(dict)
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

// TODO: change to extension
func convertToDictionary(text: String) -> [String: Any]? {
    if let data = text.data(using: .utf8) {
        do {
            return try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any]
        } catch {
            print(error.localizedDescription)
        }
    }
    return nil
}
