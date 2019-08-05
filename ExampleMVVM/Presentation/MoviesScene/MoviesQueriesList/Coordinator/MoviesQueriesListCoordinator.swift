//
//  MoviesQueriesListCoordinator.swift
//  ExampleMVVM
//
//  Created by Oleh Kudinov on 03.03.19.
//

import UIKit

protocol MoviesQueriesListCoordinatorDependencies {
    func makeMoviesQueriesDataSource() -> MoviesQueriesDataSourceInterface
}

class MoviesQueriesListCoordinator: Coordinator {
    var childCoordinators: [Coordinator] = []

    var navigationController: UINavigationController
    
    private let moviesQueriesListViewModelDelegate: MoviesQueriesListViewModelDelegate
    private let dependencies: MoviesQueriesListCoordinatorDependencies
    
    init(navigationController: UINavigationController,
         moviesQueriesListViewModelDelegate: MoviesQueriesListViewModelDelegate,
         dependencies: MoviesQueriesListCoordinatorDependencies) {
        self.navigationController = navigationController
        self.moviesQueriesListViewModelDelegate = moviesQueriesListViewModelDelegate
        self.dependencies = dependencies
    }
    
    func start() {
        let viewModel = MoviesQueriesListViewModel(numberOfQueriesToShow: 10,
                                                   moviesQueriesDataSource: dependencies.makeMoviesQueriesDataSource(),
                                                   delegate: moviesQueriesListViewModelDelegate)
        let vc = MoviesQueriesTableViewController.instantiate(with: viewModel)
        navigationController.pushViewController(vc, animated: false)
    }
}
