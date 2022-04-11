//
//  ModelPicker.swift
//  ModelPicker
//
//  Created by Michal Šimík on 09.02.2022.
//

import PartialSheet
import SwiftUI
import Firebase

@main
struct ModelPicker: App {

    init() {
        FirebaseApp.configure()
    }

    var body: some Scene {
        WindowGroup {
            MainContentView()
                .attachPartialSheetToRoot()
        }
    }
}
