//
//  DIContainer.swift
//  ExampleMVVM
//
//  Created by Oleh Kudinov on 01.10.18.
//

import Foundation
import  UIKit

// Dependencies that have to exist during all app life cicle
class AppDIContainer {
    
    lazy var appConfigurations = AppConfigurations()
    
    // MARK: - Network
    lazy var apiDataTransferService: DataTransferInterface = {
        
        let config = ApiDataNetworkConfig(baseURL: URL(string: appConfigurations.apiBaseURL)!,
                                          apiKey: appConfigurations.apiKey)
        let apiDataNetwork = NetworkService(session: URLSession.shared,
                                            config: config)
        return DataTransferService(with: apiDataNetwork)
    }()
    lazy var imageDataTransferService: DataTransferInterface = {
        let config = ApiDataNetworkConfig(baseURL: URL(string: appConfigurations.imagesBaseURL)!)
        let carrierLogosDataNetwork = NetworkService(session: URLSession.shared,
                                                     config: config)
        return DataTransferService(with: carrierLogosDataNetwork)
    }()
}

extension AppDIContainer: MoviesSceneDIContainerDependencies {}
