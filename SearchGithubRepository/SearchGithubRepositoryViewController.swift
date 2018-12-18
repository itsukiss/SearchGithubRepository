//
//  SearchGithubRepositoryViewController.swift
//  SearchGithubRepository
//
//  Created by 田中 厳貴 on 2018/12/13.
//  Copyright © 2018年 田中 厳貴. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

class SearchGithubRepositoryViewController: UIViewController {
    
    private let disposeBag = DisposeBag()
    @IBOutlet weak var searchBar: UISearchBar! {
        didSet {
            searchBar.placeholder = "Search Repositries..."
        }
    }
    @IBOutlet weak var tableView: UITableView! {
        didSet {
            tableView.register(UINib(nibName: "SearchGithubRepositoryCell", bundle: nil), forCellReuseIdentifier: "SearchGithubRepositoryCell")
            tableView.tableFooterView = UIView()
        }
    }
    @IBOutlet weak var errorView: UIView! {
        didSet {
            errorView.isHidden = true
        }
    }
    
    @IBOutlet weak var errorLabel: UILabel!
    
    
    lazy var viewModel: SearchGithubRepositoryViewModel = {
        return SearchGithubRepositoryViewModel(searchText: searchBar.rx.text.orEmpty.asObservable())
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        bindViewModel()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.isNavigationBarHidden = true
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.isNavigationBarHidden = false
    }

    private func bindViewModel() {
        
    tableView.rx.modelSelected(SearchGithubRepositoryModel.Repository.self)
        .observeOn(MainScheduler.instance)
        .subscribe(onNext: { [weak self] repository in
            guard let pageUrl = URL(string: repository.htmlURL) else { return }
            let webViewVC = WebViewController.instantiate(url: pageUrl)
            self?.navigationController?.pushViewController(webViewVC, animated: true)
        }).disposed(by: disposeBag)
        
        viewModel.repositories
            .bind(to: tableView.rx.items(cellIdentifier: "SearchGithubRepositoryCell", cellType: SearchGithubRepositoryCell.self)) { _, element, cell in
                cell.repository = element
            }.disposed(by: disposeBag)
        
        viewModel.error
            .observeOn(MainScheduler.instance)
            .subscribe(onNext: { [weak self] error in
                guard let error = error as? SearchGithubRepositoryModel.GithubSearchError else { return }
                self?.errorLabel.text = error.localizedDescription
                self?.errorView.isHidden = false
            }).disposed(by: disposeBag)
    }
}

