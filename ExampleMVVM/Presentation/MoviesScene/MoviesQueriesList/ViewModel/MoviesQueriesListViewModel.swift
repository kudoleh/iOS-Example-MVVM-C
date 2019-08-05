//
//  MoviesQueriesListViewModel.swift
//  ExampleMVVM
//
//  Created by Oleh Kudinov on 03.10.18.
//

import Foundation

protocol MoviesQueriesListViewModelDelegate {
    func moviesQueriesListDidSelect(movieQuery: MovieQuery)
}

class MoviesQueriesListViewModel: MVVMViewModel {
    
    struct Item: Equatable {
        let query: String
    }
    
    private(set) var items: Observable<[Item]> = Observable([Item]())
    
    let numberOfQueriesToShow: Int
    let moviesQueriesDataSource: MoviesQueriesDataSourceInterface
    let delegate: MoviesQueriesListViewModelDelegate
    
    init(numberOfQueriesToShow: Int,
         moviesQueriesDataSource: MoviesQueriesDataSourceInterface,
         delegate: MoviesQueriesListViewModelDelegate) {
        self.numberOfQueriesToShow = numberOfQueriesToShow
        self.moviesQueriesDataSource = moviesQueriesDataSource
        self.delegate = delegate
    }
    
    private func updateMoviesQueries() {
        self.items.value = moviesQueriesDataSource.recentsQueries(number: numberOfQueriesToShow).map{ Item(query: $0.query) }
    }
}

// MARK: - Event methods from view
extension MoviesQueriesListViewModel {
    func viewWillAppear() {
        updateMoviesQueries()
    }
    
    func viewDidLoad() {
        
    }
    
    func didSelect(item: MoviesQueriesListViewModel.Item) {
        delegate.moviesQueriesListDidSelect(movieQuery: MovieQuery(query: item.query))
    }
}
