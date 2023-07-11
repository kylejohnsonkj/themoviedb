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
    
    var movie: Movie!
}

class MovieTableViewController: UITableViewController {

    let fetcher = MovieFetcher()
    let imageCache = AppDelegate.imageCache

    var movies: [Movie] = [] {
        didSet {
            tableView.backgroundView = movies.isEmpty ? noResultsLabel : nil
            tableView.reloadData()
        }
    }
    
    var noResultsLabel: UILabel {
        let label = UILabel()
        label.numberOfLines = 0
        label.text = "\n\n\n\n\nNo results"
        label.textColor = .systemGray
        label.textAlignment = .center
        return label
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        // setup title
        navigationItem.title = "Movie Search"
        navigationController?.navigationBar.prefersLargeTitles = true
        
        // add search bar to navigation item
        let searchController = UISearchController(searchResultsController: nil)
        searchController.delegate = self
        searchController.searchBar.delegate = self
        searchController.hidesNavigationBarDuringPresentation = false
        navigationItem.searchController = searchController
        
        // show label if data source is empty
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
            print("Failed to initialize MovieCell, returning empty cell")
            return UITableViewCell()
        }
        
        let movie = movies[indexPath.row]
        cell.movie = movie
        cell.titleLabel.text = movie.title
        cell.yearLabel.text = Util.formatYear(dateString: movie.releaseDate)
        cell.posterImageView.image = nil // clear previous image, if any
        
        // pull poster from cache if already downloaded
        if let image = imageCache.object(forKey: movie.id as NSNumber) {
            cell.posterImageView.image = image
        } else if let posterPath = movie.posterPath {
            Task {
                do {
                    // fetch movie poster if not cached
                    if let image = try await fetcher.getMoviePoster(posterPath: posterPath) {
                        imageCache.setObject(image, forKey: movie.id as NSNumber)
                        
                        // before setting image, check that movie for cell has not changed
                        if movies.count > indexPath.row, movie.id == cell.movie.id {
                            cell.posterImageView.image = image
                        }
                    }
                } catch {
                    Util.showErrorAlert(vc: self, error: error)
                }
            }
        }
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let selectedMovie = movies[indexPath.row]
        performSegue(withIdentifier: "toDetail", sender: selectedMovie)
    }
    
    // MARK: - Navigation

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // pass the selected movie to the detail page
        if let vc = segue.destination as? MovieDetailTableViewController,
           let selectedMovie = sender as? Movie {
            vc.movie = selectedMovie
        }
    }
}

// MARK: - UISearch Delegates

extension MovieTableViewController: UISearchControllerDelegate {
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        movies = []
    }
}

extension MovieTableViewController: UISearchBarDelegate {
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        guard !searchText.isEmpty else {
            movies = []
            return
        }
        // fetch the movies for the given search query
        Task {
            do {
                movies = try await fetcher.getMovies(searchText: searchText)
            } catch {
                Util.showErrorAlert(vc: self, error: error)
            }
        }
    }
}
