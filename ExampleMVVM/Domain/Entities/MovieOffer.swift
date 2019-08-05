//
//  MovieOffer.swift
//  ExampleMVVM
//
//  Created by Oleh Kudinov on 17.06.19.
//

import Foundation

typealias MovieOfferId = Int

struct MovieOffer {
    let id: MovieOfferId
    let name: String
}

extension MovieOffer: Equatable {
    static func == (lhs: MovieOffer, rhs: MovieOffer) -> Bool {
        return (lhs.id == rhs.id)
    }
}

extension MovieOffer: Hashable {
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
}
