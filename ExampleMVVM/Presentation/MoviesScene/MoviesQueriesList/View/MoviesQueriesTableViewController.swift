//
//  MoviesQueriesTableViewController.swift
//  ExampleMVVM
//
//  Created by Oleh Kudinov on 03.10.18.
//

import Foundation
import UIKit

class MoviesQueriesTableViewController: UITableViewController, MVVMView, StoryboardInstantiable {
    
    var viewModel: MoviesQueriesListViewModel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.tableFooterView = UIView()
        tableView.backgroundColor = .clear
        
        bind(to: viewModel)
    }
    
    func bind(to viewModel: MoviesQueriesListViewModel) {
        viewModel.items.observe(on: self) { [unowned self] _ in
            self.tableView.reloadData()
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        
        super.viewWillAppear(animated)
        viewModel.viewWillAppear()
    }
}

// MARK: - UITableViewDataSource, UITableViewDelegate
extension MoviesQueriesTableViewController {
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.items.value.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: MoviesQueriesItemCell.reuseIdentifier, for: indexPath) as! MoviesQueriesItemCell
        cell.fill(with: viewModel.items.value[indexPath.row])
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: false)
        viewModel.didSelect(item: viewModel.items.value[indexPath.row])
    }
}
