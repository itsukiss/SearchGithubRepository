//
//  SearchGithubRepositoryViewModelTests.swift
//  SearchGithubRepositoryTests
//
//  Created by marty-suzuki on 2018/12/18.
//  Copyright © 2018年 田中 厳貴. All rights reserved.
//

import RxCocoa
import RxSwift
import RxTest
import XCTest
@testable import SearchGithubRepository

final class SearchGithubRepositoryViewModelTests: XCTestCase {

    private var dependency: Dependency!

    override func setUp() {
        dependency = Dependency()
    }

    func test_search_repositories() {
        let repository = SearchGithubRepositoryModel.Repository(id: 1,
                                                                fullName: "tanaka",
                                                                htmlURL: "https://github.com")
        let repositories = SearchGithubRepositoryModel.Repositories(totalCount: 1,
                                                                    incompleteResults: false,
                                                                    items: [repository])
        let disposeBag = DisposeBag()

        let searchResults = BehaviorRelay<[SearchGithubRepositoryModel.Repository]>(value: [])
        dependency.viewModel.repositories
            .bind(to: searchResults)
            .disposed(by: disposeBag)

        let searchTextResult = BehaviorRelay<String?>(value: nil)
        dependency.loadSearchURLParam
            .bind(to: searchTextResult)
            .disposed(by: disposeBag)

        let searchText = "test"

        dependency.searchText.accept(searchText)
        dependency.scheduler.advanceTo(dependency.scheduler.clock + 1)
        dependency.repositoriesResponse.accept(repositories)

        guard let searchTextResultValue = searchTextResult.value else {
            XCTFail(" searchTextResult.value is nil")
            return
        }

        XCTAssertEqual(searchTextResultValue, searchText)

        guard let repositoryResult = searchResults.value.first else {
            XCTFail("searchResults.value.first is nil")
            return
        }

        XCTAssertEqual(repositoryResult.id, repository.id)
        XCTAssertEqual(repositoryResult.htmlURL, repository.htmlURL)
        XCTAssertEqual(repositoryResult.fullName, repository.fullName)    }
}

extension SearchGithubRepositoryViewModelTests {
    private struct Dependency {
        let scheduler: TestScheduler

        let repositoriesResponse: PublishRelay<SearchGithubRepositoryModel.Repositories?>
        let searchText = PublishRelay<String>()

        let loadSearchURLParam: Observable<String>

        let viewModel: SearchGithubRepositoryViewModel

        init() {
            self.scheduler = TestScheduler(initialClock: 0)

            let _repositoriesResponse = PublishRelay<SearchGithubRepositoryModel.Repositories?>()
            self.repositoriesResponse = _repositoriesResponse

            let _loadSearchURLParam = PublishRelay<String>()
            self.loadSearchURLParam = _loadSearchURLParam.asObservable()

            let loadSearchURL: (String) -> Observable<SearchGithubRepositoryModel.Repositories?> = {
                _loadSearchURLParam.accept($0)
                return _repositoriesResponse.asObservable()
            }
            self.viewModel = SearchGithubRepositoryViewModel(searchText: searchText.asObservable(),
                                                             concurrentMainScheduler: scheduler,
                                                             loadSearchURL: loadSearchURL)
        }
    }
}
