//
//  MoviesListViewItemModel.swift
//  ExampleMVVM
//
//  Created by Oleh Kudinov on 18.02.19.
//

import Foundation

extension MoviesListViewModel {
    
    class Item: MVVMViewModel, Equatable {
        
        let id: Int
        let title: String
        let overview: String
        let releaseDate: String
        var posterPath: String?
        private(set) var posterImage: Observable<Data?> = Observable(nil)
        private let posterImagesDataSource: PosterImagesDataSourceInterface
        private var imageLoadTask: Cancellable? { willSet { imageLoadTask?.cancel() } }

        init(movie: Movie,
             posterImagesDataSource: PosterImagesDataSourceInterface) {
            self.id = movie.id
            self.title = movie.title
            self.posterPath = movie.posterPath
            self.overview = movie.overview
            self.releaseDate = movie.releaseDate != nil ? dateFormatter.string(from: movie.releaseDate!) : NSLocalizedString("To be announced", comment: "")
            self.posterImagesDataSource = posterImagesDataSource
        }
        
        func updatePosterImage(width: Int) {
            posterImage.value = nil
            guard let posterPath = posterPath else { return }
            
            imageLoadTask = posterImagesDataSource.image(with: posterPath, width: width) { [weak self] (result: Result<Data, Error>) in
                guard self?.posterPath == posterPath else { return }
                switch result {
                case .success(let data):
                    self?.posterImage.value = data
                case .failure: break
                }
                self?.imageLoadTask = nil
            }
        }
    }
}

// MARK: - View event methods
extension MoviesListViewModel.Item {
    func viewDidLoad() {}
}

func ==(lhs: MoviesListViewModel.Item, rhs: MoviesListViewModel.Item) -> Bool {
    return (lhs.id == rhs.id)
}

fileprivate let dateFormatter: DateFormatter = {
    let formatter = DateFormatter()
    formatter.dateStyle = .medium
    return formatter
}()
