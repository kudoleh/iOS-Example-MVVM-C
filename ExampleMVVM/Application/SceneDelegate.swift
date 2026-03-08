//
//  SceneDelegate.swift
//  ExampleMVVM
//
//  Created by Codex on 08.03.26.
//

import UIKit

@available(iOS 13.0, *)
class SceneDelegate: UIResponder, UIWindowSceneDelegate {

    var window: UIWindow?
    private var mainCoordinator: AppMainCoordinator?

    func scene(_ scene: UIScene,
               willConnectTo session: UISceneSession,
               options connectionOptions: UIScene.ConnectionOptions) {
        guard let windowScene = scene as? UIWindowScene else { return }

        let window = UIWindow(windowScene: windowScene)
        let navigationController = UINavigationController()

        window.rootViewController = navigationController

        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else { return }
        mainCoordinator = AppMainCoordinator(navigationController: navigationController,
                                             appDIContainer: appDelegate.appDIContainer)
        mainCoordinator?.start()

        self.window = window
        window.makeKeyAndVisible()
    }
}
