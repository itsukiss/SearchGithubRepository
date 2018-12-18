//
//  SearchGithubRepositoryCell.swift
//  SearchGithubRepository
//
//  Created by 田中 厳貴 on 2018/12/13.
//  Copyright © 2018年 田中 厳貴. All rights reserved.
//

import UIKit

class SearchGithubRepositoryCell: UITableViewCell {
    
    @IBOutlet weak var repositoryNameLabel: UILabel!
    
    var repository: SearchGithubRepositoryModel.Repository? {
        didSet {
            guard let repository = repository else { return }
            repositoryNameLabel.text = repository.fullName
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
}
