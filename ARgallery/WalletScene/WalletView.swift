//
//  WalletView.swift
//  ModelPicker
//
//  Created by Michal Šimík on 09.02.2022.
//

import SwiftUI
import Introspect
import UIKit
import CachedAsyncImage

struct WalletView: View {
    @ObservedObject var viewModel: MainContentViewModel
    @Environment(\.presentationMode) var presentationMode

    var body: some View {
        NavigationView {
            VStack {
                HStack {
                    TextField("Enter wallet address", text: $viewModel.address)
                        .frame(height: 50)
                        .padding([.leading, .trailing], 16)
                        .introspectTextField { textField in
                            textField.clearButtonMode = .always
                        }
                    Button {
                        viewModel.getCollectibles()
                        viewModel.saveAddress()
                    } label: {
                        Text("Load").font(.system(size: 13, weight: .semibold))
                    }
                    .padding(.trailing, 10)
                }

                HStack {
                    Text("List of NFTs")
                        .padding(.leading, 16)
                    Spacer()
                }

                List(viewModel.collectibles, id: \.name) { collectible in
                    CollectibleRow(collectible: collectible)
                }
                .listStyle(.plain)
            }
            .navigationTitle("Crypto wallet")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar(content: {
                Button {
                    presentationMode.wrappedValue.dismiss()
                } label: {
                    Text("Close")
                }
            })
        }
    }
}

struct CollectibleRow: View {
    var collectible: Collectible

    var body: some View {
        HStack {
            CachedAsyncImage(url: collectible.getCollectibleURL(), urlCache: .imageCache) { image in
                image
                    .resizable()
                    .scaledToFill()
            } placeholder: {
                ProgressView()
            }
            .frame(width: 40, height: 40)
            .cornerRadius(5)
            Text(collectible.name ?? "N/A")
        }
    }
}

struct LandmarkRow_Previews: PreviewProvider {
    static var previews: some View {
        CollectibleRow(collectible: Collectible(tokenAddress: "address", tokenId: "id", name: "test", tokenUri: nil, metadata: nil))
    }
}
