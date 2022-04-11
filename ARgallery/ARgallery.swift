//
//  ModelPicker.swift
//  ModelPicker
//
//  Created by Michal Šimík on 09.02.2022.
//

import PartialSheet
import SwiftUI

@main
struct ModelPicker: App {
    var body: some Scene {
        WindowGroup {
            MainContentView()
                .attachPartialSheetToRoot()
        }
    }
}
