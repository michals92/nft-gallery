//
//  MoralisService.swift
//  ModelPicker
//
//  Created by Michal Šimík on 09.02.2022.
//

import Foundation
import FTAPIKit

protocol MoralisService {
    func collectibles(_ address: String, chain: String, format: String, completion: @escaping (Result<Collectibles, APIErrorStandard>) -> Void)
}

final class MoralisCollectiblesService: MoralisService {
    private let apiAdapter: MoralisApiAdapter

    init(apiAdapter: MoralisApiAdapter) {
        self.apiAdapter = apiAdapter
    }

    func collectibles(_ address: String, chain: String = "eth", format: String = "decimal", completion: @escaping (Result<Collectibles, APIErrorStandard>) -> Void) {

        let endpoint = MoralisNftEndpoint(chain: chain, format: format, address: address)

        apiAdapter.call(response: endpoint) { result in
            switch result {
            case .success(let response):
                completion(.success(response))
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
}
