//
//  MoralisServer.swift
//  ModelPicker
//
//  Created by Michal Šimík on 09.02.2022.
//

import Foundation
import FTAPIKit

struct MoralisServer: URLServer {
    let baseUri = URL(string: "https://deep-index.moralis.io/api/v2/")!
    let urlSession = URLSession(configuration: .default)

    let decoding: Decoding = JSONDecoding { decoder in
        decoder.keyDecodingStrategy = .convertFromSnakeCase
    }

    let encoding: Encoding = JSONEncoding { encoder in
        encoder.keyEncodingStrategy = .convertToSnakeCase
    }

    func buildRequest(endpoint: Endpoint) throws -> URLRequest {
        var request = try buildStandardRequest(endpoint: endpoint)
        request.addValue("fDAllNEMtyx3k8B4amvnei1zPnQqzHyENyTnYsyIVFG6BLQDD9vaTvj38TOqByjI", forHTTPHeaderField: "X-API-Key")
        request.addValue("application/json", forHTTPHeaderField: "accept")
        return request
    }
}

struct MoralisNftEndpoint: ResponseEndpoint {
    typealias Response = Collectibles

    init(chain: String, format: String, address: String) {
        let chain = URLQueryItem(name: "chain", value: chain)
        let format = URLQueryItem(name: "format", value: format)
        query = URLQuery(items: [chain, format])
        path = "\(address)/nft"
    }

    let query: URLQuery
    let path: String
    let method: HTTPMethod = .get
}
