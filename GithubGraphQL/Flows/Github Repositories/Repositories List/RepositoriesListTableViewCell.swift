//
//  RepositoriesListTableViewCell.swift
//  GithubGraphQL
//
//  Created by Pedro Gomes Rubbo Pacheco on 03/03/22.
//  Copyright © 2022 test. All rights reserved.
//

import UIKit
import Kingfisher

class RepositoriesListTableViewCell: UITableViewCell {


    @IBOutlet weak var repositoryNameLabel: UILabel!
    @IBOutlet weak var repositoryUrlLabel: UILabel!
    @IBOutlet weak var repositoryRating: UILabel!
    @IBOutlet weak var userImageView: UIImageView!
    
    override func prepareForReuse() {
        repositoryUrlLabel.text = nil
        repositoryNameLabel.text = nil
        repositoryRating.text = nil
        userImageView.image = nil
    }
    
    func configureUI(cellViewModel: RepositoriesListCellViewModel) {
        userImageView.kf.setImage(with: cellViewModel.userImageUrl)
        repositoryUrlLabel.text = cellViewModel.url
        repositoryNameLabel.text = cellViewModel.repositoryName
        repositoryRating.attributedText = cellViewModel.stars
    }

}
