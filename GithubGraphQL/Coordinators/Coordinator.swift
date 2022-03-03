//
//  Coordinator.swift
//  GithubGraphQL
//
//  Created by Pedro Gomes Rubbo Pacheco on 03/03/22.
//  Copyright © 2022 test. All rights reserved.
//

import UIKit

enum CoordinatorEvent {
    case goToRepositoryDetails(repositoryDetails: RepositoryDetails)
}

protocol Coordinator {
    var navigationController: UINavigationController? { get set }
    
    func eventOccurred(with type: CoordinatorEvent)
    func start()
}

protocol Coordinating {
    var coordinator: Coordinator? { get set }
    static func instantiate() -> Self
}

extension Coordinating where Self: UIViewController {
    static func instantiate() -> Self {
        let fullName = NSStringFromClass(self)

        let className = fullName.components(separatedBy: ".")[1]

        let storyboard = UIStoryboard(name: className, bundle: Bundle.main)

        return storyboard.instantiateInitialViewController() as! Self
    }
}
