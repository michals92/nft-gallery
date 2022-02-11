//
//  WalletView.swift
//  ModelPicker
//
//  Created by Michal Šimík on 09.02.2022.
//

import SwiftUI

struct WalletView: View {
    var collectibles: [Collectible]
    @Binding var address: String

    var body: some View {
        NavigationView {
           // TextField("wallet address", text: $address)
            List(collectibles, id: \.name) { collectible in
                CollectibleRow(collectible: collectible)
            }
        }.navigationTitle("Wallet NFTs")
    }
}

struct CollectibleRow: View {
    var collectible: Collectible

    var body: some View {
        Text(collectible.name ?? "N/A")
    }
}

struct LandmarkRow_Previews: PreviewProvider {
    static var previews: some View {
        CollectibleRow(collectible: Collectible(tokenAddress: "address", tokenId: "id", name: "test", tokenUri: nil, metadata: nil))
    }
}
