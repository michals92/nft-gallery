//
//  ShareImagesView.swift
//  ARgallery
//
//  Created by Michal Šimík on 08.03.2022.
//

import SwiftUI

struct ShareImagesView: View {
    var image: UIImage

    var body: some View {
        NavigationView {
            VStack {
                Image(uiImage: image)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
            }
            .navigationTitle("Share photo")
            .navigationBarTitleDisplayMode(.inline)
        }
    }
}
