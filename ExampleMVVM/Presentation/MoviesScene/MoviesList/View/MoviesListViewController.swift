//
//  MoviesListViewController.swift
//  ExampleMVVM
//
//  Created by Oleh Kudinov on 01.10.18.
//

import Foundation
import UIKit

class MoviesListViewController: UIViewController, MVVMView, StoryboardInstantiable, Alertable {
    
    @IBOutlet weak var contentView: UIView!
    @IBOutlet weak var moviesListContainer: UIView!
    @IBOutlet weak var suggestionsListContainer: UIView!
    @IBOutlet weak var searchBarContainer: UIView!
    @IBOutlet weak var loadingView: UIActivityIndicatorView!
    @IBOutlet weak var emptyStateStackView: UIStackView!
    @IBOutlet weak var emptyStateIconImageView: UIImageView!
    @IBOutlet weak var emptyStateTitleLabel: UILabel!
    @IBOutlet weak var emptyStateSubtitleLabel: UILabel!
    
    var viewModel: MoviesListViewModel!
    
    private var moviesTableViewController: MoviesListTableViewController?
    var searchController = UISearchController(searchResultsController: nil)
    private let searchDebouncer: Debouncer = DefaultDebouncer(delay: 0.4)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = NSLocalizedString("Movies", comment: "")
        setupSearchController()
        
        bind(to: viewModel)
        viewModel.viewDidLoad()
    }
    
    func bind(to viewModel: MoviesListViewModel) {
        viewModel.items.observe(on: self) { [unowned self] (items: [MoviesListViewModel.Item])  in
            self.moviesTableViewController?.items = items
            self.updateViewsVisibility(model: self.viewModel)
        }
        viewModel.query.observe(on: self) { [unowned self] (query: String) in
            self.updateSearchController(query: query)
        }
        viewModel.error.observe(on: self) { [unowned self] (error: String) in
            self.showError(error)
        }
        viewModel.loadingType.observeAndFire(on: self) { [unowned self] _ in
            self.updateViewsVisibility(model: self.viewModel)
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        searchDebouncer.cancel()
        searchController.isActive = false
    }
    
    private func updateSearchController(query: String) {
        // Live search already keeps the search bar's text in sync with `query` as the user types,
        // so only force-sync (and dismiss search) when the query changed from elsewhere, e.g. a selected suggestion.
        guard searchController.searchBar.text != query else { return }
        searchController.isActive = false
        searchController.searchBar.text = query
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == String(describing: MoviesListTableViewController.self),
            let destinationVC = segue.destination as? MoviesListTableViewController {
            
            moviesTableViewController = destinationVC
            moviesTableViewController?.viewModel = viewModel
        }
    }

    func showError(_ error: String) {
        guard !error.isEmpty else { return }
        showAlert(title: NSLocalizedString("Error", comment: ""), message: error)
    }
    
    private func updateViewsVisibility(model: MoviesListViewModel) {
        loadingView.isHidden = true
        emptyStateStackView.isHidden = true
        moviesListContainer.isHidden = true
        suggestionsListContainer.isHidden = true
        moviesTableViewController?.update(isLoadingNextPage: false)
        
        if model.loadingType.value == .fullScreen {
            loadingView.isHidden = false
        } else if model.loadingType.value == .nextPage {
            moviesTableViewController?.update(isLoadingNextPage: true)
            moviesListContainer.isHidden = false
        } else if model.isEmpty {
            updateEmptyState()
            emptyStateStackView.isHidden = false
        } else {
            moviesListContainer.isHidden = false
        }
        updateQuerySuggestionsVisibility()
    }
    
    private func updateEmptyState() {
        let query = viewModel.query.value
        if query.isEmpty {
            emptyStateIconImageView.image = UIImage(systemName: "magnifyingglass")
            emptyStateTitleLabel.text = NSLocalizedString("Search Movies", comment: "")
            emptyStateSubtitleLabel.text = NSLocalizedString("Type a title above and results will appear as you type.", comment: "")
        } else {
            let format = NSLocalizedString("No movies found for \u{201c}%@\u{201d}. Try another title.", comment: "")
            emptyStateIconImageView.image = UIImage(systemName: "film")
            emptyStateTitleLabel.text = NSLocalizedString("No Results", comment: "")
            emptyStateSubtitleLabel.text = String(format: format, query)
        }
    }

    @IBAction private func startSearchButtonTapped(_ sender: UIButton) {
        searchController.searchBar.becomeFirstResponder()
    }

    private func updateQuerySuggestionsVisibility() {
        // Suggestions only make sense while the field is focused and still empty.
        let isEmptyField = (searchController.searchBar.text ?? "").isEmpty
        setQueriesSuggestionsView(isVisible: searchController.searchBar.isFirstResponder && isEmptyField)
    }
    
    private func setQueriesSuggestionsView(isVisible: Bool) {
        if isVisible {
            viewModel.showQueriesSuggestions()
        } else {
            viewModel.closeQueriesSuggestions()
        }
        suggestionsListContainer.isHidden = !isVisible
    }
}

extension MoviesListViewController: UISearchBarDelegate {
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        searchDebouncer.cancel()
        updateQuerySuggestionsVisibility()

        guard !searchText.isEmpty else {
            viewModel.didCancelSearch()
            return
        }

        searchDebouncer.execute { [weak self] in
            self?.viewModel.didSearch(query: searchText)
        }
    }

    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        guard let searchText = searchBar.text, !searchText.isEmpty else { return }
        searchDebouncer.cancel()
        searchController.isActive = false
        moviesTableViewController?.tableView.setContentOffset(CGPoint.zero, animated: false)
        viewModel.didSearch(query: searchText)
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        searchDebouncer.cancel()
        viewModel.didCancelSearch()
    }
}

extension MoviesListViewController: UISearchControllerDelegate {
    public func willPresentSearchController(_ searchController: UISearchController) {
        updateQuerySuggestionsVisibility()
    }
    
    public func willDismissSearchController(_ searchController: UISearchController) {
        updateQuerySuggestionsVisibility()
    }

    public func didDismissSearchController(_ searchController: UISearchController) {
        updateQuerySuggestionsVisibility()
    }
}

// MARK: - Setup Search Controller

extension MoviesListViewController {
    private func setupSearchController() {
        searchController.delegate = self
        searchController.searchBar.delegate = self
        searchController.searchBar.placeholder = NSLocalizedString("Search Movies", comment: "")
        if #available(iOS 9.1, *) {
            searchController.obscuresBackgroundDuringPresentation = false
        } else {
            searchController.dimsBackgroundDuringPresentation = true
        }
        searchController.searchBar.translatesAutoresizingMaskIntoConstraints = true
        searchController.searchBar.barStyle = .black
        searchController.searchBar.frame = searchBarContainer.bounds
        searchController.searchBar.autoresizingMask = [.flexibleWidth]
        searchBarContainer.addSubview(searchController.searchBar)
        definesPresentationContext = true
    }
}
