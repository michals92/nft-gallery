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
struct ModelPicker: App, RouterProtocol {

    @State var route: BasicRoute

    init() {
        FirebaseApp.configure()

        let route = BasicRoute(rawValue: UserDefaults.standard.string(forKey: "current-route") ?? "onboarding") ?? .onboarding
        self.route = route
    }

    var body: some Scene {
        WindowGroup {
            switch route {
            case .main:
                MainContentView(router: self).attachPartialSheetToRoot()
            case .onboarding:
                OnboardingView(router: self)
            }
        }
    }

    func presentRoute(_ route: BasicRoute) {
        self.route = route
    }
}
