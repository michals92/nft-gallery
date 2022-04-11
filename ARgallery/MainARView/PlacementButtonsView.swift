//
//  PlacementButtonsView.swift
//  ARgallery
//
//  Created by Michal Šimík on 27.02.2022.
//

import SwiftUI

struct PlacementButtonsView: View {
    @Binding var isPlacementEnabled: Bool
    @Binding var selectedModel: Collectible?
    @Binding var modelConfirmedForPlacement: Collectible?
    @Binding var isBox: Bool

    var body: some View {
        HStack(spacing: 0) {
            Spacer()
            Button(action: {
                isBox.toggle()
            }, label: {
                Label {
                    Text(isBox ? "3D BOX" : "POSTER")
                } icon: {
                    Image(systemName: "square.on.circle")
                }.foregroundColor(.white)
            })
            .frame(minWidth: 0, maxWidth: .infinity)
            Spacer()
            Button(action: {
                modelConfirmedForPlacement = selectedModel
                resetPlacementParameters()
            }, label: {
                Image(systemName: "checkmark")
                    .resizable()
                    .renderingMode(.template)
                    .foregroundColor(Color.white)
                    .background(Image("background"))
                    .scaledToFit()
                    .padding()
                    .frame(width: 60, height: 60)
                    .cornerRadius(30)
            })
            .frame(minWidth: 0, maxWidth: .infinity)
            Spacer()
            Button(action: {
                resetPlacementParameters()
            }, label: {
                Text("CANCEL").foregroundColor(.white)
            })
            .frame(minWidth: 0, maxWidth: .infinity)
            Spacer()
        }
        .padding(.top, 10)
    }

    func resetPlacementParameters() {
        isPlacementEnabled = false
        selectedModel = nil
    }
}
