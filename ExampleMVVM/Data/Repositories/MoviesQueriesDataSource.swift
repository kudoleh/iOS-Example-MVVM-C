//
//  MoviesQueriesDataSource.swift
//  ExampleMVVM
//
//  Created by Oleh Kudinov on 15.02.19.
//

import Foundation

class MoviesQueriesDataSource {
    
    private let dataTransferService: DataTransferInterface
    private var moviesQueriesPersistentStorage: MoviesQueriesStorageInterface
    
    init(dataTransferService: DataTransferInterface, moviesQueriesPersistentStorage: MoviesQueriesStorageInterface) {
        self.dataTransferService = dataTransferService
        self.moviesQueriesPersistentStorage = moviesQueriesPersistentStorage
    }
}

extension MoviesQueriesDataSource: MoviesQueriesDataSourceInterface {
    
    func recentsQueries(number: Int) -> [MovieQuery] {
        return moviesQueriesPersistentStorage.recentsQueries(number: number)
    }
    
    func saveRecentQuery(query: MovieQuery) {
        moviesQueriesPersistentStorage.saveRecentQuery(query: query)
    }
}
