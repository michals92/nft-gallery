//
//  ContentView.swift
//  ModelPicker
//
//  Created by Radovan Vránsky on 26/01/2022.
//

import SwiftUI

struct MainContentView: View {
    @ObservedObject private var viewModel = MainContentViewModel()
    @State private var isBox = false
    @State private var isFrontCamera = false

    var body: some View {
        NavigationView {
            ZStack(alignment: .bottom) {
                ARViewContainer(isPlacementEnabled: $viewModel.isPlacementEnabled,
                                collectibleForPlacement: $viewModel.collectibleForPlacement,
                                isBox: $isBox,
                                isFrontCamera: $isFrontCamera)
                    .edgesIgnoringSafeArea(.all)
                    .padding(.bottom, 100)

                VStack {
                    if viewModel.address == "" {
                        Text("Please import Wallet!")
                    } else if !viewModel.isPlacementEnabled {
                        PlacementButtonsView(isPlacementEnabled: $viewModel.isPlacementEnabled,
                                             selectedModel: $viewModel.selectedModel,
                                             modelConfirmedForPlacement: $viewModel.collectibleForPlacement,
                                             isBox: $isBox)
                    } else {
                        ModelPickerView(isPlacementEnabled: $viewModel.isPlacementEnabled,
                                        selectedModel: $viewModel.selectedModel,
                                        collectibles: $viewModel.collectibles,
                                        isFrontCamera: $isFrontCamera,
                                        viewModel: viewModel)
                    }
                }
                .background(Color(uiColor: .primaryBackgroundColor))
                .overlay(
                    Rectangle()
                        .frame(width: .none, height: 0.5, alignment: .top)
                        .foregroundColor(Color(uiColor: .ternaryTextColor))
                    , alignment: .top)
            }
            .navigationBarHidden(true)
        }
        .onAppear(perform: viewModel.getCollectibles)
    }
}

#if DEBUG
struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        MainContentView()
    }
}
#endif
