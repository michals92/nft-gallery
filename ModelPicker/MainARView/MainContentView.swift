//
//  ContentView.swift
//  ModelPicker
//
//  Created by Radovan Vránsky on 26/01/2022.
//

import SwiftUI
import SDWebImageSwiftUI

struct MainContentView: View {
    @StateObject private var viewModel = MainContentViewModel()

    var body: some View {
        NavigationView {
            ZStack(alignment: .bottom) {
                ARViewContainer(collectibleForPlacement: $viewModel.collectibleForPlacement)
                VStack {
                    if viewModel.isPlacementEnabled {
                        PlacementButtonsView(isPlacementEnabled: $viewModel.isPlacementEnabled,
                                             selectedModel: $viewModel.selectedModel,
                                             modelConfirmedForPlacement: $viewModel.collectibleForPlacement)
                    } else {
                        ModelPickerView(isPlacementEnabled: $viewModel.isPlacementEnabled,
                                        selectedModel: $viewModel.selectedModel,
                                        collectibles: $viewModel.collectibles)
                    }

//                    if !viewModel.collectibles.isEmpty {
//                        NavigationLink(destination: WalletView(collectibles: viewModel.collectibles, address: $viewModel.testAddress)) {
//                            Text("Wallet detail")
//                        }.hidden()
//                    }
                    Spacer()
                    .frame(height: 40)
                }
                    .background(Color.black.opacity(0.5))
            }.edgesIgnoringSafeArea([.bottom, .top])

        }
        .navigationBarHidden(true)
        .onAppear(perform: viewModel.getCollectibles)
    }
}

// MARK: model picker view

struct ModelPickerView: View {
    @Binding var isPlacementEnabled: Bool
    @Binding var selectedModel: Collectible?
    @Binding var collectibles: [Collectible]

    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 30) {
                ForEach(collectibles, id: \.self) { collectible in
                    Button {
                        selectedModel = collectible
                        isPlacementEnabled = true
                    } label: {
                        let dict = convertToDictionary(text: collectible.metadata ?? "")
                        let imageString = dict?["image"] as? String
                //        AnimatedImage(url: URL(string: imageString ?? "")!)
                        Text(collectible.name ?? "")
                            //.resizable()
                         //   .placeholder { ProgressView() }
                            .frame(width: 60, height: 60)
                    }
                }
            }
            .padding(10)
        }
    }
}

// MARK: placement buttons view

struct PlacementButtonsView: View {
    @Binding var isPlacementEnabled: Bool
    @Binding var selectedModel: Collectible?
    @Binding var modelConfirmedForPlacement: Collectible?

    var body: some View {
        HStack {
            Button(action: {
                print("cross")
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
                print("check")
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
