//
//  MovieTableViewController.swift
//  TheMovieDB
//
//  Created by Kyle Johnson on 7/10/23.
//

import UIKit

class MovieCell: UITableViewCell {
    @IBOutlet weak var posterImageView: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var yearLabel: UILabel!
}

class MovieTableViewController: UITableViewController {

    let fetcher = MovieFetcher()
    var movies: [Movie] = [] {
        didSet {
            tableView.backgroundView = movies.isEmpty ? noResultsLabel : nil
        }
    }
    
    var imageCache = NSCache<NSNumber, UIImage>()
    var noResultsLabel: UILabel {
        let label = UILabel()
        label.text = "No results"
        label.textColor = .systemGray
        label.textAlignment = .center
        return label
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        // setup title
        navigationItem.title = "Movie Search"
        navigationController?.navigationBar.prefersLargeTitles = true
        
        // add search bar
        let searchController = UISearchController(searchResultsController: nil)
        searchController.delegate = self
        searchController.searchBar.delegate = self
        searchController.hidesNavigationBarDuringPresentation = false
        navigationItem.searchController = searchController
        
        // reveal label if no data
        tableView.backgroundView = noResultsLabel
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return movies.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "movieCell", for: indexPath) as? MovieCell else {
            print("Failed to dequeue reusable cell, returning empty cell")
            return UITableViewCell()
        }
        
        let movie = movies[indexPath.row]
        cell.titleLabel.text = movie.title
        cell.yearLabel.text = DateUtils.formatYear(from: movie.releaseDate)
        cell.posterImageView.image = nil
        
        // pull poster from cache if already downloaded
        if let image = imageCache.object(forKey: movie.id as NSNumber) {
            cell.posterImageView.image = image
        } else if let posterPath = movie.posterPath {
            Task {
                if let image = try await fetcher.fetchMoviePoster(posterPath: posterPath) {
                    imageCache.setObject(image, forKey: movie.id as NSNumber)
                    
                    await MainActor.run {
                        // before setting image, check that movie for cell has not changed
                        if movies.count > indexPath.row, movie.id == movies[indexPath.row].id {
                            cell.posterImageView.image = image
                        }
                    }
                }
            }
        }
        return cell
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}

extension MovieTableViewController: UISearchControllerDelegate {
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        movies = []
        tableView.reloadData()
    }
}

extension MovieTableViewController: UISearchBarDelegate {
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        guard !searchText.isEmpty else {
            movies = []
            tableView.reloadData()
            return
        }
        Task {
            movies = try await fetcher.loadMovies(searchText: searchText)
            await MainActor.run {
                tableView.reloadData()
            }
        }
    }
}
