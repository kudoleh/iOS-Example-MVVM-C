//
//  FetchMovieOfferUseCase.swift
//  ExampleMVVM
//
//  Created by Oleh Kudinov on 17.06.19.
//

import Foundation

protocol FetchMovieOfferUseCaseInterface {
    func execute(requestValue: FetchMovieOfferUseCaseRequestValue,
                 completion: @escaping (Result<MovieOffer, Error>) -> Void)
}

class FetchMovieOfferUseCase: FetchMovieOfferUseCaseInterface {

    func execute(requestValue: FetchMovieOfferUseCaseRequestValue,
                 completion: @escaping (Result<MovieOffer, Error>) -> Void) {
        
        DispatchQueue.global(qos: .background).async {
            // TODO: Implement download movie offer request and remove sleep()
            sleep(1)
            completion(.success(MovieOffer(id: 0, name: "Movie Offer")))
        }
    }
}

struct FetchMovieOfferUseCaseRequestValue {
    let query: MovieQuery
}
