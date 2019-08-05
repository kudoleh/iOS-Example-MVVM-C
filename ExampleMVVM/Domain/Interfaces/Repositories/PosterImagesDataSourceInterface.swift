//
//  PosterImagesDataSourceInterface.swift
//  ExampleMVVM
//
//  Created by Oleh Kudinov on 01.10.18.
//

import Foundation

protocol PosterImagesDataSourceInterface {
    
    func image(with imagePath: String, width: Int, result: @escaping (Result<Data, Error>) -> Void) -> Cancellable?
}
