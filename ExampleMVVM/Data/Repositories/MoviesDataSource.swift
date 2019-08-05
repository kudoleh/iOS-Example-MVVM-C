//
//  moviesDataSource.swift
//  ExampleMVVM
//
//  Created by Oleh Kudinov on 01.10.18.
//

import Foundation

class MoviesDataSource {
    
    private let dataTransferService: DataTransferInterface
    
    init(dataTransferService: DataTransferInterface) {
        self.dataTransferService = dataTransferService
    }
}

extension MoviesDataSource: MoviesDataSourceInterface {

    func moviesList(query: MovieQuery, page: Int, with result: @escaping (Result<MoviesPage, Error>) -> Void) -> Cancellable? {
        let endpoint = APIEndpoints.movies(query: query.query, page: page)
        
        return self.dataTransferService.request(with: endpoint) { (response: Result<MoviesPage, Error>) in
            switch response {
            case .success(let moviesPage):
                result(.success(moviesPage))
                return
            case .failure(let error):
                result(.failure(error))
                return
            }
        }
    }
}
