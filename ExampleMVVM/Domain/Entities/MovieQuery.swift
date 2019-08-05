//
//  MovieQuery.swift
//  ExampleMVVM
//
//  Created by Oleh Kudinov on 03.10.18.
//

import Foundation

struct MovieQuery {
    let query: String
}

extension MovieQuery: Equatable {
    static func == (lhs: MovieQuery, rhs: MovieQuery) -> Bool {
        return (lhs.query == rhs.query)
    }
}
