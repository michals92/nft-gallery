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
            Spacer()
            Button {
                isBox.toggle()
            } label: {
                Text(isBox ? "krabice" : "obraz").padding(.trailing, 10)
            }
        }
    }

    func resetPlacementParameters() {
        isPlacementEnabled = false
        selectedModel = nil
    }
}
