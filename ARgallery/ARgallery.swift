//
//  ModelPicker.swift
//  ModelPicker
//
//  Created by Michal Šimík on 09.02.2022.
//

import SwiftUI
import PartialSheet

@main
struct ModelPicker: App {
    var body: some Scene {
        WindowGroup {
            MainContentView()
                .attachPartialSheetToRoot()
        }
    }
}
