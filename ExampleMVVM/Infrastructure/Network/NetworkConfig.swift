//
//  ServiceConfig.swift
//  ExampleMVVM
//
//  Created by Oleh Kudinov on 01.10.18.
//

import Foundation

public protocol NetworkConfigurable {
    var baseURL: URL { get }
    var headers: [String: String] { get }
    var apiKey: String? { get }
    var queryParameters: [String: String] { get }
}

public struct ApiDataNetworkConfig: NetworkConfigurable {
    public let baseURL: URL
    public let headers: [String: String]
    public let apiKey: String?
    public var queryParameters: [String: String] {
        guard let apiKey = apiKey else { return [:] }
        return ["api_key": apiKey]
    }
    
     public init(baseURL: URL, headers: [String: String] = [:], apiKey: String? = nil) {
        self.baseURL = baseURL
        self.headers = headers
        self.apiKey = apiKey
    }
}
