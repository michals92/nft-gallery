//
//  ModelPickerView.swift
//  ARgallery
//
//  Created by Michal Šimík on 27.02.2022.
//

import CachedAsyncImage
import PartialSheet
import SwiftUI

struct ModelPickerView: View {
    @Binding var isPlacementEnabled: Bool
    @Binding var selectedModel: Collectible?
    @Binding var collectibles: [Collectible]
    @Binding var isFrontCamera: Bool
    @Binding var removeObjects: Bool

    @State private var showingDetail = false

    @ObservedObject var viewModel: MainContentViewModel

    let iPhoneStyle = PSIphoneStyle(
        background: .solid(Color(uiColor: .primaryBackgroundColor)),
        handleBarStyle: .solid(.secondary),
        cover: .enabled(Color.black.opacity(0.4)),
        cornerRadius: 10
    )

    var body: some View {
        VStack(spacing: 20) {
            HStack {
                Text("PICK NFT")
                    .font(.system(size: 13, weight: .semibold))
                    .foregroundColor(Color(uiColor: .ternaryTextColor))
                    .padding(.top, 10)
                    .padding(.bottom, -10)
                    .padding([.leading, .trailing], 16)
                Spacer()
            }
            ScrollView(.horizontal, showsIndicators: false) {
                LazyHStack(spacing: 10) {
                    ForEach(collectibles.indices, id: \.self) { index in
                        Button {
                            selectedModel = collectibles[index]
                            isPlacementEnabled = true
                        } label: {
                            CachedAsyncImage(url: collectibles[index].getCollectibleURL(), urlCache: .imageCache) { image in
                                image
                                    .resizable()
                                    .scaledToFill()
                            } placeholder: {
                                ProgressView()
                            }
                            .frame(width: 56, height: 56)
                            .cornerRadius(12)
                        }
                    }
                }
                .padding(16)
            }
            .frame(height: 56)
            HStack {
                Spacer()
                Button {
                    if viewModel.moralisService.walletAddress != nil {
                        showingDetail = true
                    } else {
                        let route = BasicRoute.onboarding
                        UserDefaults.standard.set(route.rawValue, forKey: "current-route")
                        viewModel.router.presentRoute(route)
                    }
                } label: {
                    VStack {
                        Image(systemName: "gear")
                            .resizable()
                            .renderingMode(.template)
                            .foregroundColor(.white)
                            .padding(15)
                            .scaledToFit()
                    }
                }
                .frame(width: 60, height: 60)
                .partialSheet(isPresented: $showingDetail, iPhoneStyle: iPhoneStyle, content: {
                    WalletView(viewModel: viewModel)
                })
                Button {
                    print("empty")
                } label: {
                    Image("")
                        .resizable()
                        .renderingMode(.template)
                        .foregroundColor(.white)
                        .padding(15)
                        .scaledToFit()
                }
                .frame(width: 60, height: 60)
                Spacer()
                Button {
                    viewModel.takeSnapshot = true
                } label: {
                    Image("camera")
                }
                .frame(width: 70, height: 70)
                Spacer()
                HStack {
                    Button {
                        isFrontCamera.toggle()
                    } label: {
                        Image(systemName: "arrow.triangle.2.circlepath.camera")
                            .resizable()
                            .renderingMode(.template)
                            .foregroundColor(.white)
                            .padding(15)
                            .scaledToFit()
                    }
                    .frame(width: 60, height: 60)
                    Button {
                        removeObjects = true
                    } label: {
                        VStack {
                            Image(systemName: "trash")
                                .resizable()
                                .renderingMode(.template)
                                .foregroundColor(.white)
                                .padding(15)
                                .scaledToFit()
                        }
                    }
                    .frame(width: 60, height: 60)
                    .partialSheet(isPresented: $showingDetail, iPhoneStyle: iPhoneStyle, content: {
                        WalletView(viewModel: viewModel)
                    })
                }
                Spacer()
            }
            .frame(maxWidth: .infinity, alignment: .center)
        }
    }
}
