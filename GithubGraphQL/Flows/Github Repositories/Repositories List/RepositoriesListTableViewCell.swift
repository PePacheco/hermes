//
//  RepositoriesListTableViewCell.swift
//  GithubGraphQL
//
//  Created by Pedro Gomes Rubbo Pacheco on 03/03/22.
//  Copyright © 2022 test. All rights reserved.
//

import UIKit

class RepositoriesListTableViewCell: UITableViewCell {

    @IBOutlet weak var userNameLabel: UILabel!
    @IBOutlet weak var repositoryNameLabel: UILabel!
    @IBOutlet weak var repositoryUrlLabel: UILabel!

    override func prepareForReuse() {
        userNameLabel.text = nil
        repositoryNameLabel = nil
        repositoryUrlLabel = nil
    }
    
    func configureUI(cellViewModel: RepositoriesListCellViewModel) {
        userNameLabel.text = cellViewModel.userName
        // repositoryNameLabel.text = cellViewModel.repositoryName
        // repositoryUrlLabel.text = cellViewModel.url
    }

}
