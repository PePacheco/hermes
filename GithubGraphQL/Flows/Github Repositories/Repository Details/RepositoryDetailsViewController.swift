//
//  RepositoryDetailsViewController.swift
//  GithubGraphQL
//
//  Created by Pedro Gomes Rubbo Pacheco on 03/03/22.
//  Copyright © 2022 test. All rights reserved.
//

import UIKit

class RepositoryDetailsViewController: UIViewController, Coordinating {
    
    var coordinator: Coordinator?
    private var viewModel: RepositoryDetailsViewModel?

    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    func configureViewModel(with model: RepositoryDetails) {
        viewModel = RepositoryDetailsViewModel(with: model)
        print(model)
    }
    
}
