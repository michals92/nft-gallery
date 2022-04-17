//
//  OnboardingView.swift
//  ARgallery
//
//  Created by Michal Šimík on 17.04.2022.
//

import SwiftUI
import Introspect

struct OnboardingView: View {
    let router: RouterProtocol

    let moralisService = MoralisCollectiblesService(apiAdapter: MoralisApiAdapter())

    @State var enterWalletAddress = false
    @State var hasCorrectAddress = false
    @State var address: String = ""
    @State var nftCount = 0

    init(router: RouterProtocol) {
        self.router = router
    }

    private func fetchCollectiblesCount() {
        moralisService.collectiblesCount(for: address) { result in
            switch result {
            case let .success(count):
                DispatchQueue.main.async {
                    nftCount = count
                }
            case .failure:
                DispatchQueue.main.async {
                    nftCount = 0
                }
            }
        }
    }

    private func setWalletAddress() -> Bool {
        if nftCount > 0 {
            moralisService.setWalletAddress(address)
            return true
        } else {
            return false
        }
    }

    private func showMainScreen() {
        let route = BasicRoute.main
        UserDefaults.standard.set(route.rawValue, forKey: "current-route")
        router.presentRoute(route)
    }

    var body: some View {
        VStack {
            Spacer()
            if !enterWalletAddress {
                VStack(spacing: 30) {
                    Image("nft-icon").resizable().frame(width: 160, height: 160, alignment: .center)
                    Text("Welcome to NoFoTo app")
                        .font(.system(size: 24))
                        .multilineTextAlignment(.center)
                    Text("Place your NFTs into the real world using augmented reality")
                        .font(.system(size: 16))
                        .multilineTextAlignment(.center)
                }
                .padding(24)
            } else {
                VStack(spacing: 30) {
                    Text("Enter ethereum wallet address")
                        .font(.system(size: 24))
                        .multilineTextAlignment(.center)
                    TextField("Enter wallet address", text: $address)
                        .introspectTextField(customize: { textField in
                            textField.clearButtonMode = .whileEditing
                        })
                        .onChange(of: address) { value in
                            print(value)
                            if value.count == 42 {
                                fetchCollectiblesCount()
                            } else {
                                nftCount = 0
                            }
                        }
                    Text("\(nftCount) NFTs found for this wallet!")
                        .font(.system(size: 16))
                        .multilineTextAlignment(.center)
                }
                .padding(24)
            }
            Spacer()
            if enterWalletAddress {
                Button {
                    showMainScreen()
                } label: {
                    Text("SKIP WITH DEMO ADDRESS")
                        .font(.system(size: 13, weight: .semibold))
                        .foregroundColor(Color(uiColor: .secondaryTextColor))
                }
            }
            HStack {
                Spacer()
                Button {
                    if enterWalletAddress {
                        if setWalletAddress() {
                            showMainScreen()
                        } else {
                            // TODO: show alert that address is not correct
                        }
                    }

                    enterWalletAddress = true
                } label: {
                    LinearGradient(gradient: Gradient(colors: [Color(hex: 0xC9123E), Color(hex: 0xCB2BAB)]),
                                   startPoint: .topLeading,
                                   endPoint: .bottomTrailing)
                    .mask(
                        Text(enterWalletAddress ? "START" : "ENTER WALLET")
                            .font(.system(size: 13, weight: .semibold))
                    )
                }
                Spacer()
            }
            .frame(height: 44)
            .background(Color.white)
            .cornerRadius(22)
            .padding(16)
        }
    }
}
