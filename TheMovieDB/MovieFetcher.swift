//
//  MovieFetcher.swift
//  TheMovieDB
//
//  Created by Kyle Johnson on 7/10/23.
//

import UIKit

struct MovieResponse: Decodable {
    let results: [Movie]
}

struct Movie: Decodable {
    let id: Int
    let title: String
    let releaseDate: String
    let posterPath: String?
    let voteAverage: Double
    let voteCount: Int
    let overview: String
    
    // keep to Swift conventions by removing underscores in keys
    enum CodingKeys: String, CodingKey {
        case id
        case title
        case releaseDate = "release_date"
        case posterPath = "poster_path"
        case voteAverage = "vote_average"
        case voteCount = "vote_count"
        case overview
    }
}

struct MovieFetcher {
    func getMovies(searchText: String) async throws -> [Movie] {
        guard let query = searchText.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) else {
            print("Invalid search query, returning empty results")
            return []
        }
        let apiKey = AppDelegate.TMDB_API_KEY
        if apiKey == "<TMDB_API_KEY_HERE>" {
            throw(NSError(domain: "com.kylejohnson.TheMovieDB", code: 0, userInfo: [NSLocalizedDescriptionKey: "API key missing from AppDelegate"]))
        }
        let urlString = "https://api.themoviedb.org/3/search/movie?api_key=\(apiKey)&language=en-US&query=\(query)&page=1&include_adult=false"
        guard let url = URL(string: urlString) else {
            print("Failed to create url for search, returning empty results")
            return []
        }
        let (data, _) = try await URLSession.shared.data(from: url)
        let response = try JSONDecoder().decode(MovieResponse.self, from: data)
        return response.results
    }
    
    func getMoviePoster(posterPath: String) async throws -> UIImage? {
        let urlString = "https://image.tmdb.org/t/p/original/\(posterPath)"
        guard let url = URL(string: urlString) else {
            print("Failed to create url for poster, returning nil")
            return nil
        }
        let (data, _) = try await URLSession.shared.data(from: url)
        return UIImage(data: data)
    }
}
