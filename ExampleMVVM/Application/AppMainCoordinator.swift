//
//  AppCoordinator.swift
//  ExampleMVVM
//
//  Created by Oleh Kudinov on 03.03.19.
//

import UIKit

class AppMainCoordinator: Coordinator {
    
    var childCoordinators: [Coordinator] = []
    
    var navigationController: UINavigationController
    private let appDIContainer: AppDIContainer
    
    init(navigationController: UINavigationController,
         appDIContainer: AppDIContainer) {
        self.navigationController = navigationController
        self.appDIContainer = appDIContainer
    }
    
    func start() {
        
        let coordinator = MoviesListViewCoordinator(navigationController: navigationController,
                                                    dependencies: MoviesSceneDIContainer(dependencies: appDIContainer))
        coordinator.start()
        childCoordinators.append(coordinator)
    }
}
