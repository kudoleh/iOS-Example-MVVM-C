//
//  FetchMoviesUseCase.swift
//  ExampleMVVM
//
//  Created by Oleh Kudinov on 22.02.19.
//

import Foundation

protocol FetchMoviesUseCaseInterface {
    func execute(requestValue: FetchMoviesUseCaseRequestValue,
                 completion: @escaping (Result<MoviesPage, Error>) -> Void) -> Cancellable?
}

class FetchMoviesUseCase: FetchMoviesUseCaseInterface {
    let moviesDataSource: MoviesDataSourceInterface
    let moviesQueriesDataSource: MoviesQueriesDataSourceInterface
    
    init(moviesDataSource: MoviesDataSourceInterface, moviesQueriesDataSource: MoviesQueriesDataSourceInterface) {
        self.moviesDataSource = moviesDataSource
        self.moviesQueriesDataSource = moviesQueriesDataSource
    }
    
    func execute(requestValue: FetchMoviesUseCaseRequestValue,
                 completion: @escaping (Result<MoviesPage, Error>) -> Void) -> Cancellable? {
        return moviesDataSource.moviesList(query: requestValue.query, page: requestValue.page) { [weak self] result in
            guard let weakSelf = self else { return }
            
            switch result {
            case .success:
                weakSelf.moviesQueriesDataSource.saveRecentQuery(query: requestValue.query)
                return completion(result)
            case .failure:
                return completion(result)
            }
        }
    }
}

struct FetchMoviesUseCaseRequestValue {
    let query: MovieQuery
    let page: Int
}
