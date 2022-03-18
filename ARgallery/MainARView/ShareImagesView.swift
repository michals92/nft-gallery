//
//  ShareImagesView.swift
//  ARgallery
//
//  Created by Michal Šimík on 08.03.2022.
//

import SwiftUI

struct ShareImagesView: View {
    @State private var showShareSheet = false
    var image: UIImage {
        didSet {
            
        }
    }

    var body: some View {
        NavigationView {
            VStack {
                Image(uiImage: image)
                    .resizable()
                    .aspectRatio(contentMode: .fit)

                Button {
                    showShareSheet = true
                } label: {
                    LinearGradient(gradient: Gradient(colors: [Color(hex: 0xC9123E), Color(hex: 0xCB2BAB)]),
                                   startPoint: .topLeading,
                                   endPoint: .bottomTrailing)
                    .mask(
                        Text("SHARE")
                            .font(.system(size: 13, weight: .semibold))
                    )
                }
                .frame(width: 90, height: 30)
                .background(Color(uiColor: .secondaryTextColor))
                .cornerRadius(15)
            }
            .navigationTitle("Share photo")
            .navigationBarTitleDisplayMode(.inline)
            .sheet(isPresented: $showShareSheet) {
                ShareSheet(activityItems: [image])
            }
        }
    }
}
