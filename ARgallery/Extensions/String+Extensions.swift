//
//  String+Extensions.swift
//  ARgallery
//
//  Created by Michal Šimík on 20.02.2022.
//

import Foundation

extension String {
    func convertToDictionary() -> [String: Any]? {
        if let data = data(using: .utf8) {
            do {
                return try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any]
            } catch {
                print(error.localizedDescription)
                return nil
            }
        }
        return nil
    }
}
