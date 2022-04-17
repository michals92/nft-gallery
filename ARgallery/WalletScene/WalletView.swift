//
//  WalletView.swift
//  ModelPicker
//
//  Created by Michal Šimík on 09.02.2022.
//

import CachedAsyncImage
import Introspect
import SwiftUI
import UIKit

struct WalletView: View {
    @ObservedObject var viewModel: MainContentViewModel
    @Environment(\.presentationMode) var presentationMode
    @State var editWallet = false
    @FocusState private var focusedField: FocusField?

    enum FocusField: Hashable {
        case field
    }

    var body: some View {
        NavigationView {
            VStack {
                HStack {
                    Text("ETHEREUM WALLET")
                        .font(Font.system(size: 13, weight: .semibold))
                        .foregroundColor(Color(uiColor: .ternaryTextColor))
                    Spacer()
                }
                .padding([.top, .leading, .trailing], 16)
                if editWallet {
                    TextField("Enter wallet address", text: $viewModel.tempAddress)
                        .introspectTextField(customize: { textField in
                            textField.clearButtonMode = .whileEditing
                        })
                        .onAppear {
                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.6) {
                                self.focusedField = .field
                            }
                        }
                        .onChange(of: viewModel.tempAddress) { value in
                            // TODO: - fetch number of nfts
                            print(value)
                            print(viewModel.collectibles.count)
                        }
                        .focused($focusedField, equals: .field)
                        .padding()
                    HStack(alignment: .center, spacing: 20) {
                        Spacer()
                        Button {
                            viewModel.tempAddress = viewModel.address
                            editWallet = false
                        } label: {
                            Text("CANCEL")
                                .font(.system(size: 13, weight: .semibold))
                                .foregroundColor(Color(uiColor: .secondaryTextColor))
                        }
                        .frame(width: 90, height: 30)
                        .background(Color(uiColor: .secondaryBackgroundColor))
                        .cornerRadius(15)

                        Button {
                            editWallet = false
                            viewModel.address = viewModel.tempAddress
                            viewModel.saveAddress()
                        } label: {
                            LinearGradient(gradient: Gradient(colors: [Color(hex: 0xC9123E), Color(hex: 0xCB2BAB)]),
                                           startPoint: .topLeading,
                                           endPoint: .bottomTrailing)
                                .mask(
                                    Text("CONFIRM")
                                        .font(.system(size: 13, weight: .semibold))
                                )
                        }
                        .frame(width: 90, height: 30)
                        .background(Color(uiColor: .secondaryTextColor))
                        .cornerRadius(15)
                        Spacer()
                    }
                } else {
                    Text(viewModel.address)
                        .padding([.leading, .trailing], 16)
                    Divider()
                    HStack {
                        Text("\(viewModel.collectibles.count) NFTs available for this wallet")
                            .padding(.leading, 16)
                        Spacer()
                        Button {
                            editWallet = true
                        } label: {
                            LinearGradient(gradient: Gradient(colors: [Color(hex: 0xC9123E), Color(hex: 0xCB2BAB)]),
                                           startPoint: .topLeading,
                                           endPoint: .bottomTrailing)
                                .frame(width: 90, height: 30)
                                .mask(
                                    Text("CHANGE")
                                        .font(.system(size: 13, weight: .semibold))
                                )
                        }
                        .frame(width: 90, height: 30)
                        .background(Color(uiColor: .secondaryTextColor))
                        .cornerRadius(15)
                    }
                    .padding(.trailing, 16)
                }
                Spacer()
            }
            .background(Color(uiColor: .primaryBackgroundColor))
            .navigationBarHidden(true)
        }
        .frame(height: 200)
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
