//
//  SearchGithubRepositoryModel.swift
//  SearchGithubRepository
//
//  Created by 田中 厳貴 on 2018/12/13.
//  Copyright © 2018年 田中 厳貴. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa

struct SearchGithubRepositoryModel {
    
    private static let rootURL = "https://api.github.com/search/repositories?q="
    
    struct Repositories: Decodable {
        let totalCount: Int
        let incompleteResults: Bool
        let items: [Repository]
        
        enum CodingKeys: String, CodingKey {
            case totalCount = "total_count"
            case incompleteResults = "incomplete_results"
            case items
        }
    }
    
    struct Repository: Decodable {
        let id: Int
        let fullName: String
        let htmlURL: String
        
        enum CodingKeys: String, CodingKey {
            case id
            case fullName = "full_name"
            case htmlURL = "html_url"
        }
    }
    
    enum GithubSearchError: Error {
        case parseError
        case apiError(Int)
        
        var localizedDescription: String {
            switch self {
            case .parseError:
                return "Parse Error"
            case .apiError(let errorCode):
                return "API Error: \(errorCode)"
            }
        }
    }
    
    public static func loadSearchURL(_ searchWord: String) -> Observable<Repositories?> {
        guard !searchWord.isEmpty else { return Observable.just(nil)}
        guard let query = searchWord.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed), let url = URL(string: rootURL + query) else { return Observable.error(GithubSearchError.parseError)}
        return URLSession.shared
            .rx.response(request: URLRequest(url: url))
            .retry(3)
            .observeOn(SerialDispatchQueueScheduler(qos: .default))
            .flatMap { pair -> Observable<Repositories?> in
                if pair.0.statusCode == 403 {
                    return Observable.error(GithubSearchError.apiError(pair.0.statusCode))
                }
                
                do {
                let repositories = try JSONDecoder().decode(Repositories.self, from: pair.1)
                    
                    return Observable.just(repositories)
                } catch {
                    return Observable.error(GithubSearchError.parseError)
                }
                
            }
    }
}
