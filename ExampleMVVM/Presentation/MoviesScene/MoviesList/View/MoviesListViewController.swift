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
    @IBOutlet weak var emptyDataLabel: UILabel!
    
    var viewModel: MoviesListViewModel!
    
    private var moviesTableViewController: MoviesListTableViewController?
    var searchController = UISearchController(searchResultsController: nil)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = NSLocalizedString("Movies", comment: "")
        emptyDataLabel.text = NSLocalizedString("Search results ", comment: "")
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
        searchController.isActive = false
    }
    
    private func updateSearchController(query: String) {
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
        emptyDataLabel.isHidden = true
        moviesListContainer.isHidden = true
        suggestionsListContainer.isHidden = true
        moviesTableViewController?.update(isLoadingNextPage: false)
        
        if model.loadingType.value == .fullScreen {
            loadingView.isHidden = false
        } else if model.loadingType.value == .nextPage {
            moviesTableViewController?.update(isLoadingNextPage: true)
            moviesListContainer.isHidden = false
        } else if model.isEmpty {
            emptyDataLabel.isHidden = false
        } else {
            moviesListContainer.isHidden = false
        }
        updateQuerySuggestionsVisibility()
    }
    
    private func updateQuerySuggestionsVisibility() {
        setQueriesSuggestionsView(isVisible: searchController.searchBar.isFirstResponder)
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
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        guard let searchText = searchBar.text, !searchText.isEmpty else { return }
        searchController.isActive = false
        moviesTableViewController?.tableView.setContentOffset(CGPoint.zero, animated: false)
        viewModel.didSearch(query: searchText)
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
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
