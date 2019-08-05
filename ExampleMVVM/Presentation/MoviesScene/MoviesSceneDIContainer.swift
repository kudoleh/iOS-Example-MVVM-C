//
//  MoviesSceneDIContainer.swift
//  ExampleMVVM
//
//  Created by Oleh Kudinov on 03.03.19.
//

import Foundation
import  UIKit

protocol MoviesSceneDIContainerDependencies {
    var apiDataTransferService: DataTransferInterface { get }
    var imageDataTransferService: DataTransferInterface { get }
}

// Dependencies that exist only during life cicle of the movie scene
class MoviesSceneDIContainer {
    
    private let dependencies: MoviesSceneDIContainerDependencies
    
    init(dependencies: MoviesSceneDIContainerDependencies) {
        self.dependencies = dependencies
    }
    
    // MARK: - Persistent Storage
    lazy var moviesQueriesStorage = MoviesQueriesStorage()
    
    // MARK: - Use Cases
    func makeFetchMoviesUseCase() -> FetchMoviesUseCaseInterface {
        return FetchMoviesUseCase(moviesDataSource: makeMoviesDataSource(),
                                                       moviesQueriesDataSource: makeMoviesQueriesDataSource())
    }
    
    func makeFetchMovieOfferUseCase() -> FetchMovieOfferUseCaseInterface {
        return FetchMovieOfferUseCase()
    }
    
    // MARK: - Data Sources
    func makeMoviesDataSource() -> MoviesDataSourceInterface {
        return MoviesDataSource(dataTransferService: dependencies.apiDataTransferService)
    }
    func makeMoviesQueriesDataSource() -> MoviesQueriesDataSourceInterface {
        return MoviesQueriesDataSource(dataTransferService: dependencies.apiDataTransferService,
                                       moviesQueriesPersistentStorage: moviesQueriesStorage)
    }
    func makePosterImagesDataSource() -> PosterImagesDataSourceInterface  {
        return PosterImagesDataSource(dataTransferService: dependencies.imageDataTransferService,
                                      imageNotFoundData: UIImage(named: "image_not_found")?.pngData())
    }
}

extension MoviesSceneDIContainer: MoviesListViewCoordinatorDependencies, MoviesQueriesListCoordinatorDependencies {}
