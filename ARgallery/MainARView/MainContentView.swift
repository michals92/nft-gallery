//
//  ContentView.swift
//  ModelPicker
//
//  Created by Radovan Vránsky on 26/01/2022.
//

import SwiftUI

struct MainContentView: View {
    @ObservedObject private var viewModel: MainContentViewModel
    @State private var isBox = false
    @State private var isFrontCamera = false
    @State private var removeObjects = false

    init(router: RouterProtocol) {
        self.viewModel = MainContentViewModel(router: router)
    }

    var body: some View {
        NavigationView {
            ZStack(alignment: .bottom) {
                ARViewContainer(isPlacementEnabled: $viewModel.isPlacementEnabled,
                                collectibleForPlacement: $viewModel.collectibleForPlacement,
                                isBox: $isBox,
                                isFrontCamera: $isFrontCamera,
                                removeObjects: $removeObjects,
                                takeSnapshot: $viewModel.takeSnapshot,
                                imageToShare: $viewModel.imageToShare)
                    .edgesIgnoringSafeArea(.all)
                    .padding(.bottom, 60)
                VStack {
                    if viewModel.isPlacementEnabled {
                        PlacementButtonsView(isPlacementEnabled: $viewModel.isPlacementEnabled,
                                             selectedModel: $viewModel.selectedModel,
                                             modelConfirmedForPlacement: $viewModel.collectibleForPlacement,
                                             isBox: $isBox)
                    } else {
                        ModelPickerView(isPlacementEnabled: $viewModel.isPlacementEnabled,
                                        selectedModel: $viewModel.selectedModel,
                                        collectibles: $viewModel.collectibles,
                                        isFrontCamera: $isFrontCamera,
                                        removeObjects: $removeObjects,
                                        viewModel: viewModel)
                    }
                }
                .background(Color(uiColor: .primaryBackgroundColor))
                .overlay(
                    Rectangle()
                        .frame(width: .none, height: 0.5, alignment: .top)
                        .foregroundColor(Color(uiColor: .ternaryTextColor)), alignment: .top
                )
            }
            .navigationBarHidden(true)
            .sheet(isPresented: $viewModel.takeSnapshot, onDismiss: {
                viewModel.takeSnapshot = false
                viewModel.imageToShare = nil
            }, content: {
                if let image = viewModel.imageToShare {
                    let height = (image.size.width / 9) * 16
                    let point = (image.size.height - height) / 2

                    if let croppedImage = image.crop(toRect: CGRect(x: 0, y: point, width: image.size.width, height: height)) {
                        ShareImagesView(image: croppedImage)
                            .padding(10)
                    }
                }
            })
        }
        .onAppear(perform: viewModel.getCollectibles)
    }
}

#if DEBUG
    struct ContentView_Previews: PreviewProvider {
        static var previews: some View {
            MainContentView(router: MockRouter())
        }
    }
#endif
