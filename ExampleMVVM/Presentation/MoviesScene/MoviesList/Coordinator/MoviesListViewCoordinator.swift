//
//  MoviesListViewCoordinator.swift
//  ExampleMVVM
//
//  Created by Oleh Kudinov on 03.03.19.
//

import UIKit

protocol MoviesListViewCoordinatorDependencies  {
    func makeFetchMoviesUseCase() -> FetchMoviesUseCaseInterface
    func makeFetchMovieOfferUseCase() -> FetchMovieOfferUseCaseInterface
    func makePosterImagesDataSource() -> PosterImagesDataSourceInterface
}

class MoviesListViewCoordinator: Coordinator {
    
    var childCoordinators: [Coordinator] = []
    var navigationController: UINavigationController
    
    typealias DependenciesType = MoviesListViewCoordinatorDependencies & MoviesQueriesListCoordinatorDependencies
    private let dependencies: DependenciesType
    
    private weak var moviesListViewController: MoviesListViewController?
    
    init(navigationController: UINavigationController,
         dependencies: DependenciesType) {
        self.navigationController = navigationController
        self.dependencies = dependencies
    }
    
    func start() {
        let viewModel = MoviesListViewModel(fetchMoviesUseCase: dependencies.makeFetchMoviesUseCase(),
                                            fetchMovieOfferUseCase: dependencies.makeFetchMovieOfferUseCase(),
                                            posterImagesDataSource: dependencies.makePosterImagesDataSource(),
                                            delegate: self)
        
        let vc = MoviesListViewController.instantiate(with: viewModel)
        navigationController.pushViewController(vc, animated: false)
        moviesListViewController = vc
    }
}

// MARK: - Navigation

extension MoviesListViewCoordinator: MoviesListViewModelDelegate {
    
    func showRecentQueries(delegate: MoviesQueriesListViewModelDelegate) {
        guard !childCoordinators.contains(where: { ($0 as? MoviesQueriesListCoordinator) != nil }),
               let moviesListViewController = moviesListViewController,
               let suggestionsListContainer = moviesListViewController.suggestionsListContainer
            else { return }
        
        let moviesQueriesListNC = UINavigationController()
        moviesQueriesListNC.isNavigationBarHidden = true
        moviesListViewController.add(child: moviesQueriesListNC, container: suggestionsListContainer)
        
        let coordinator = MoviesQueriesListCoordinator(navigationController: moviesQueriesListNC,
                                                       moviesQueriesListViewModelDelegate: delegate,
                                                       dependencies: dependencies)
        childCoordinators.append(coordinator)
        coordinator.start()
    }
    
    func closeRecentQueries() {
        guard let coordinator = childCoordinators.first( where: { ($0 as? MoviesQueriesListCoordinator) != nil }) as? MoviesQueriesListCoordinator
            else { return }
        coordinator.navigationController.remove()
        childCoordinators = childCoordinators.filter { $0 !== coordinator }
    }
}

extension UIViewController {
    func add(child: UIViewController, container: UIView) {
        addChild(child)
        container.addSubview(child.view)
        child.didMove(toParent: self)
    }
    func remove() {
        guard parent != nil else {
            return
        }
        willMove(toParent: nil)
        removeFromParent()
        view.removeFromSuperview()
    }
}
