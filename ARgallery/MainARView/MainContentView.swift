//
//  ContentView.swift
//  ModelPicker
//
//  Created by Radovan Vránsky on 26/01/2022.
//

import SwiftUI
import SDWebImageSwiftUI

struct MainContentView: View {
    @ObservedObject private var viewModel = MainContentViewModel()
    @State private var showingDetail = false

    var body: some View {
        NavigationView {
            ZStack(alignment: .bottom) {
                ARViewContainer(isPlacementEnabled: $viewModel.isPlacementEnabled, imageDataForPlacement: $viewModel.imageDataForPlacement)
                    .edgesIgnoringSafeArea(.all)
                VStack {
                    if viewModel.address == "" {
                        Text("Please import Wallet!")
                    } else if viewModel.isPlacementEnabled {
                        PlacementButtonsView(isPlacementEnabled: $viewModel.isPlacementEnabled,
                                             selectedModel: $viewModel.selectedModel,
                                             modelConfirmedForPlacement: $viewModel.imageDataForPlacement)
                    } else {
                        ModelPickerView(isPlacementEnabled: $viewModel.isPlacementEnabled,
                                        selectedModel: $viewModel.selectedModel,
                                        collectibles: $viewModel.collectibles, viewModel: viewModel)
                    }
                }
                .navigationBarHidden(true)
                closeButton
                    .padding(.trailing, 16)
                    .edgesIgnoringSafeArea(.top)
            }
        }
        .navigationBarHidden(true)
        .onAppear(perform: viewModel.getCollectibles)
    }

    var closeButton: some View {
        VStack {
            HStack {
                Spacer()
                Button {
                    showingDetail = true
                } label: {
                    VStack {
                        Image(systemName: "person")
                        Text("wallet")
                            .font(Font.caption)
                    }
                }.sheet(isPresented: $showingDetail) {
                    WalletView(viewModel: viewModel)
                }
            }
            Spacer()
        }
        .padding(.top, 42)
    }
}

// MARK: model picker view

struct ModelPickerView: View {
    @Binding var isPlacementEnabled: Bool
    @Binding var selectedModel: Data?
    @Binding var collectibles: [Collectible]

    @ObservedObject var viewModel: MainContentViewModel

    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            LazyHStack(spacing: 30) {

                ForEach(collectibles.indices, id: \.self) { index in
                    Button {
                        selectedModel = viewModel.images[index]
                        isPlacementEnabled = true
                    } label: {
                        AnimatedImage(url: collectibles[index].getCollectibleURL())
                            .onSuccess(perform: { image, _, _ in
                                viewModel.images[index] = image.pngData()
                            })
                            .resizable()
                            .placeholder { ProgressView() }
                            .frame(width: 60, height: 60)
                    }
                }
            }
            .padding(10)
        }
        .frame(height: 80)
    }
}

// MARK: placement buttons view

struct PlacementButtonsView: View {
    @Binding var isPlacementEnabled: Bool
    @Binding var selectedModel: Data?
    @Binding var modelConfirmedForPlacement: Data?

    var body: some View {
        HStack {
            Button(action: {
                resetPlacementParameters()
            }, label: {
                Image(systemName: "xmark")
                    .frame(width: 60, height: 60)
                    .font(.title)
                    .background(Color.white.opacity(0.75))
                    .cornerRadius(30)
                    .padding(20)
            })

            Button(action: {
                modelConfirmedForPlacement = selectedModel
                resetPlacementParameters()
            }, label: {
                Image(systemName: "checkmark")
                    .frame(width: 60, height: 60)
                    .font(.title)
                    .background(Color.white.opacity(0.75))
                    .cornerRadius(30)
                    .padding(10)
            })
        }
    }

    func resetPlacementParameters() {
        isPlacementEnabled = false
        selectedModel = nil
    }
}

#if DEBUG
struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        MainContentView()
    }
}
#endif
