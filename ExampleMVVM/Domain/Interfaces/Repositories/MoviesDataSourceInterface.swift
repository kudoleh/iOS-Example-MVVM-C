//
//  moviesDataSourceInterface.swift
//  ExampleMVVM
//
//  Created by Oleh Kudinov on 01.10.18.
//

import Foundation

protocol MoviesDataSourceInterface {
    @discardableResult
    func moviesList(query: MovieQuery, page: Int, with result: @escaping (Result<MoviesPage, Error>) -> Void) -> Cancellable?
}
