//
//  AppConfigurations.swift
//  ExampleMVVM
//
//  Created by Oleh Kudinov on 25.02.19.
//

import Foundation

class AppConfigurations {
    lazy var apiKey = Bundle.main.object(forInfoDictionaryKey: "ApiKey") as! String
    lazy var apiBaseURL = Bundle.main.object(forInfoDictionaryKey: "ApiBaseURL") as! String
    lazy var imagesBaseURL = Bundle.main.object(forInfoDictionaryKey: "ImageBaseURL") as! String
}
