//
//  SuggestionsItemCell.swift
//  ExampleMVVM
//
//  Created by Oleh Kudinov on 03.10.18.
//

import Foundation
import UIKit

class MoviesQueriesItemCell: UITableViewCell {
    
    static let reuseIdentifier = String(describing: MoviesQueriesItemCell.self)
    
    @IBOutlet weak var titleLabel: UILabel!
    
    func fill(with suggestion: MoviesQueriesListViewModel.Item) {
        self.titleLabel.text = suggestion.query
    }
}
