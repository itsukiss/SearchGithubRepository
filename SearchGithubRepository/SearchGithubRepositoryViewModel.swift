//
//  SearchGithubRepositoryViewModel.swift
//  SearchGithubRepository
//
//  Created by 田中 厳貴 on 2018/12/13.
//  Copyright © 2018年 田中 厳貴. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa

class SearchGithubRepositoryViewModel {
    
    private let disposeBag = DisposeBag()
    var repositories: Observable<[SearchGithubRepositoryModel.Repository]>
    var error: Observable<Error>
    
    init(searchText: Observable<String>) {
        
        let searchResult = searchText
            .distinctUntilChanged()
            .debounce(0.3, scheduler: ConcurrentMainScheduler.instance)
            .flatMap {
                return SearchGithubRepositoryModel.loadSearchURL($0).materialize()
            }
            .share()
        
        repositories = searchResult
            .flatMap { $0.element.map(Observable.just) ?? .empty() }
            .map { data in
                return data?.items ?? []
        }
        
        error = searchResult
            .flatMap { $0.error.map(Observable.just) ?? .empty() }
        
    }
}
