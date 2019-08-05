//
//  MoviesQueriesStorage.swift
//  ExampleMVVM
//
//  Created by Oleh on 03.10.18.
//

import Foundation

protocol MoviesQueriesStorageInterface {
    func recentsQueries(number: Int) -> [MovieQuery]
    func saveRecentQuery(query: MovieQuery)
}

struct MovieQueriesList: Codable {
    var list: [MovieQuery]
}

extension MovieQuery: Codable {
    private enum CodingKeys: String, CodingKey {
        case query
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.query = try container.decode(String.self, forKey: .query)
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(query, forKey: .query)
    }
}

class MoviesQueriesStorage {
    private let userDefaultsKey = "recentsMoviesQueries"
    private let maxRecentsCount = 20
    private var userDefaults: UserDefaults { return UserDefaults.standard }
    private var moviesQuries: [MovieQuery] {
        get {
            if let queriesData = userDefaults.object(forKey: userDefaultsKey) as? Data {
                let decoder = JSONDecoder()
                if let movieQueryList = try? decoder.decode(MovieQueriesList.self, from: queriesData) {
                    return movieQueryList.list
                }
            }
            return []
        }
        set {
            let encoder = JSONEncoder()
            if let encoded = try? encoder.encode(MovieQueriesList(list: newValue)) {
                userDefaults.set(encoded, forKey: userDefaultsKey)
            }
        }
    }
}

extension MoviesQueriesStorage: MoviesQueriesStorageInterface {
    func recentsQueries(number: Int) -> [MovieQuery] {
        let queries = moviesQuries
        let subrangeQueries = queries.count < number ? queries : Array(queries[0..<number])
        return subrangeQueries
    }
    func saveRecentQuery(query: MovieQuery) {
        var queries = moviesQuries
        queries = queries.filter { $0 != query }
        queries.insert(query, at: 0)
        queries = queries.count <= maxRecentsCount ? queries : Array(queries[0..<maxRecentsCount])
        moviesQuries = queries
    }
}
