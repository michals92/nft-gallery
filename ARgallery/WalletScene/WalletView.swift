//
//  WalletView.swift
//  ModelPicker
//
//  Created by Michal Šimík on 09.02.2022.
//

import SwiftUI
import Introspect
import UIKit

struct WalletView: View {
    @ObservedObject var viewModel: MainContentViewModel
    @Environment(\.presentationMode) var presentationMode

    var body: some View {
        VStack {
            HStack {
                Button("Close") {
                    presentationMode.wrappedValue.dismiss()
                }.padding(.leading, 10)
                TextField("Insert wallet address", text: $viewModel.address)
                    .frame(height: 50)
                    .padding([.leading, .trailing], 16)
                    .introspectTextField { textField in
                        textField.clearButtonMode = .always
                    }
                Button {
                    print("load address")
                    viewModel.getCollectibles()
                    viewModel.saveAddress()
                } label: {
                    Text("Load")
                }.padding(.trailing, 10)
            }

            List(viewModel.collectibles, id: \.name) { collectible in
                CollectibleRow(collectible: collectible)
            }
            .listStyle(.plain)
        }.navigationTitle("NFT wallet")
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
