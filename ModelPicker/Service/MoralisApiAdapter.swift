//
//  MoralisApiAdapter.swift
//  ModelPicker
//
//  Created by Michal Šimík on 09.02.2022.
//

import Foundation
import FTAPIKit

protocol ApiAdapter {
    func call<EP: ResponseEndpoint>(response endpoint: EP, completion: @escaping (Result<EP.Response, APIErrorStandard>) -> Void)
    func call(endpoint: Endpoint, completion: @escaping (Result<Void, APIErrorStandard>) -> Void)
   // func callImage(endpoint: Endpoint, completion: @escaping (Result<Data, APIErrorStandard>) -> Void)
}

final class MoralisApiAdapter: ApiAdapter {
    private let server = MoralisServer()

    func call<EP: ResponseEndpoint>(response endpoint: EP, completion: @escaping (Result<EP.Response, APIErrorStandard>) -> Void) {
        server.call(response: endpoint, completion: async(completion))
    }

    func call(endpoint: Endpoint, completion: @escaping (Result<Void, APIErrorStandard>) -> Void) {
        server.call(endpoint: endpoint, completion: async(completion))
    }

    private func async<T>(_ completion: @escaping (T) -> Void) -> ((T) -> Void) {
        return { arg in
            DispatchQueue.main.async {
                completion(arg)
            }
        }
    }
}
