//
//  MoviesListViewModel.swift
//  ExampleMVVM
//
//  Created by Oleh Kudinov on 01.10.18.
//

import Foundation

protocol MoviesListViewModelDelegate: AnyObject {
    func showRecentQueries(delegate: MoviesQueriesListViewModelDelegate)
    func closeRecentQueries()
}

class MoviesListViewModel: MVVMViewModel {
    
    enum LoadingType {
        case none
        case fullScreen
        case nextPage
    }
    
    private(set) var items: Observable<[Item]> = Observable([Item]())
    private(set) var loadingType: Observable<LoadingType> = Observable(.none)
    private(set) var query: Observable<String> = Observable("")
    private(set) var error: Observable<String> = Observable("")
    private(set) var currentPage: Int = 0
    private(set) var totalPageCount: Int = 1
    
    var isLoading: Bool { return loadingType.value != .none }
    var isEmpty: Bool { return items.value.isEmpty }
    var hasMorePages: Bool {
        return currentPage < totalPageCount
    }
    var nextPage: Int {
        guard hasMorePages else { return currentPage }
        return currentPage + 1
    }
    
    private let fetchMoviesUseCase: FetchMoviesUseCaseInterface
    private let fetchMovieOfferUseCase: FetchMovieOfferUseCaseInterface
    private let posterImagesDataSource: PosterImagesDataSourceInterface
    weak var delegate: MoviesListViewModelDelegate?
    
    private var moviesLoadTask: Cancellable? { willSet { moviesLoadTask?.cancel() } }
    
    @discardableResult
    init(fetchMoviesUseCase: FetchMoviesUseCaseInterface,
         fetchMovieOfferUseCase: FetchMovieOfferUseCaseInterface,
         posterImagesDataSource: PosterImagesDataSourceInterface,
         delegate: MoviesListViewModelDelegate) {
        self.fetchMoviesUseCase = fetchMoviesUseCase
        self.fetchMovieOfferUseCase = fetchMovieOfferUseCase
        self.posterImagesDataSource = posterImagesDataSource
        self.delegate = delegate
    }
    
    func appendPage(moviesPage: MoviesPage) {
        self.currentPage = moviesPage.page
        self.totalPageCount = moviesPage.totalPages
        self.items.value = items.value + moviesPage.movies.map{ MoviesListViewModel.Item(movie: $0,
                                                                                         posterImagesDataSource: posterImagesDataSource) }
    }
    
    private func resetPages() {
        currentPage = 0
        totalPageCount = 1
        items.value.removeAll()
    }
    
    private func load(movieQuery: MovieQuery, loadingType: LoadingType) {
        self.loadingType.value = loadingType
        self.query.value = movieQuery.query
        
        let dispatchGroup = DispatchGroup()
        
        dispatchGroup.enter()
        let moviesRequest = FetchMoviesUseCaseRequestValue(query: movieQuery, page: nextPage)
        moviesLoadTask = fetchMoviesUseCase.execute(requestValue: moviesRequest) { [weak self] result in
            guard let weakSelf = self else { return }
            switch result {
            case .success(let moviesPage):
                weakSelf.appendPage(moviesPage: moviesPage)
            case .failure(let error):
                weakSelf.handle(error: error)
            }
            dispatchGroup.leave()
        }
        
        dispatchGroup.enter()
        let movieOfferRequest = FetchMovieOfferUseCaseRequestValue(query: movieQuery)
        fetchMovieOfferUseCase.execute(requestValue: movieOfferRequest) { [weak self] result in
            guard let weakSelf = self else { return }
            switch result {
            case .success(let moviesOffer):
                print("Show movie offer: \(moviesOffer.name)")
            case .failure(let error):
                weakSelf.handle(error: error)
            }
            dispatchGroup.leave()
        }

        dispatchGroup.notify(queue: .main) {
            self.loadingType.value = .none
        }
    }
    
    private func handle(error: Error) {
        var errorMsg = NSLocalizedString("Failed loading movies", comment: "")
        if let error = error as? DataTransferError, case let DataTransferError.networkFailure(networkError) = error {
            errorMsg = NSLocalizedString("No internet connection", comment: "")
            if case .cancelled = networkError { return }
        }
        self.error.value = errorMsg
    }
    
    private func update(movieQuery: MovieQuery) {
        resetPages()
        load(movieQuery: movieQuery, loadingType: .fullScreen)
    }
}

// MARK: - View event methods
extension MoviesListViewModel {
    
    func viewDidLoad() {
        loadingType.value = .none
    }
    
    func didLoadNextPage() {
        guard hasMorePages, !isLoading else { return }
        load(movieQuery: MovieQuery(query: query.value),
             loadingType: .nextPage)
    }
    
    func didSearch(query: String) {
        guard !query.isEmpty else { return }
        update(movieQuery: MovieQuery(query: query))
    }
    
    func didCancelSearch() {
        moviesLoadTask?.cancel()
    }
    
    func showQueriesSuggestions() {
        delegate?.showRecentQueries(delegate: self)
    }
    
    func closeQueriesSuggestions() {
        delegate?.closeRecentQueries()
    }
}

// MARK: - Delegate method from another model views
extension MoviesListViewModel: MoviesQueriesListViewModelDelegate {
    
    func moviesQueriesListDidSelect(movieQuery: MovieQuery) {
        update(movieQuery: movieQuery)
    }
}
