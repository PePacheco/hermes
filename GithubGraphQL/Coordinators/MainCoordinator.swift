//
//  MainCoordinator.swift
//  GithubGraphQL
//
//  Created by Pedro Gomes Rubbo Pacheco on 03/03/22.
//  Copyright © 2022 test. All rights reserved.
//

import UIKit

class MainCoordinator: Coordinator {
    
    var navigationController: UINavigationController?
    
    func eventOccurred(with type: CoordinatorEvent) {
        switch type {
        case .goToRepositoryDetails(let repositoryDetails):
            break
        }
    }
    
    func start() {
        let vc: RepositoriesListViewController & Coordinating = RepositoriesListViewController.instantiate()
        vc.coordinator = self

        navigationController?.setViewControllers([vc], animated: true)
    }
}
