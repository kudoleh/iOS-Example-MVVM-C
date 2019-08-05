//
//  MoviesQueriesDataSourceInterface.swift
//  ExampleMVVM
//
//  Created by Oleh Kudinov on 15.02.19.
//

import Foundation

protocol MoviesQueriesDataSourceInterface {
    
    func recentsQueries(number: Int) -> [MovieQuery]
    func saveRecentQuery(query: MovieQuery)
}
