//
//  PosterImagesDataSource.swift
//  ExampleMVVM
//
//  Created by Oleh Kudinov on 01.10.18.
//

import Foundation

class PosterImagesDataSource {
    
    let dataTransferService: DataTransferInterface
    let imageNotFoundData: Data?
    
    init(dataTransferService: DataTransferInterface,
         imageNotFoundData: Data?) {
        self.dataTransferService = dataTransferService
        self.imageNotFoundData = imageNotFoundData
    }
}

extension PosterImagesDataSource: PosterImagesDataSourceInterface {
    
    func image(with imagePath: String, width: Int, result: @escaping (Result<Data, Error>) -> Void) -> Cancellable? {
        let endpoint = APIEndpoints.moviePoster(path: imagePath, width: width)
        
        return dataTransferService.request(with: endpoint) { [weak self] (response: Result<Data, Error>) in
            guard let weakSelf = self else { return }
            
            switch response {
            case .success(let data):
                result(.success(data))
                return
            case .failure(let error):
                if case let DataTransferError.networkFailure(networkError) = error, networkError.isNotFoundError,
                    let imageNotFoundData = weakSelf.imageNotFoundData {
                    result(.success(imageNotFoundData))
                    return
                }
                result(.failure(error))
                return
            }
        }
    }
}
