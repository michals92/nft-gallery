//
//  Router.swift
//  ARgallery
//
//  Created by Michal Šimík on 17.04.2022.
//

import Foundation

enum BasicRoute: String {
    case onboarding
    case main
}

protocol RouterProtocol {
    func presentRoute(_ route: BasicRoute)
}

class MockRouter: RouterProtocol {
    func presentRoute(_ route: BasicRoute) {

    }
}
