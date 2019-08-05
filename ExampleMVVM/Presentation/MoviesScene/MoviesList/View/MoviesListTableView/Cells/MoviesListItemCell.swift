//
//  MoviesListItemCell.swift
//  ExampleMVVM
//
//  Created by Oleh Kudinov on 01.10.18.
//

import Foundation
import UIKit

class MoviesListItemCell: UITableViewCell, MVVMView {
    
    static let reuseIdentifier = String(describing: MoviesListItemCell.self)
    static let height = CGFloat(130)
    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var overviewLabel: UILabel!
    @IBOutlet weak var posterImageView: UIImageView!
    
    var viewModel: MoviesListViewModel.Item! { didSet { unbind(from: oldValue) } }
    
    func fill(with viewModel: MoviesListViewModel.Item) {
        self.viewModel = viewModel
        titleLabel.text = viewModel.title
        dateLabel.text = "\(NSLocalizedString("Release Date", comment: "")): \(viewModel.releaseDate)"
        overviewLabel.text = viewModel.overview
        viewModel.updatePosterImage(width: Int(posterImageView.frame.size.width * UIScreen.main.scale))
        
        bind(to: viewModel)
    }
    
    func bind(to viewModel: MoviesListViewModel.Item) {
        viewModel.posterImage.observeAndFire(on: self) { [weak self] (data: Data?) in
            self?.posterImageView.image = data.flatMap{ UIImage(data: $0) }
        }
    }
    
    private func unbind(from item: MoviesListViewModel.Item?) {
        item?.posterImage.remove(observer: self)
    }
}
