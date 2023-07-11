//
//  MovieDetailTableViewController.swift
//  TheMovieDB
//
//  Created by Kyle Johnson on 7/10/23.
//

import UIKit

class MovieDetailCell: UITableViewCell {
    @IBOutlet weak var largePosterImageView: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var releaseDateLabel: UILabel!
    @IBOutlet weak var ratingLabel: UILabel!
    @IBOutlet weak var ratingProgressView: UIProgressView!
}

class MovieOverviewCell: UITableViewCell {
    @IBOutlet weak var overviewLabel: UILabel!
}

class MovieDetailTableViewController: UITableViewController {

    let fetcher = MovieFetcher()
    let imageCache = AppDelegate.imageCache
    
    var movie: Movie!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.largeTitleDisplayMode = .never
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 2
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.row == 0 {
            guard let cell = tableView.dequeueReusableCell(withIdentifier: "movieDetailCell", for: indexPath) as? MovieDetailCell else {
                print("Failed to initialize MovieDetailCell, returning empty cell")
                return UITableViewCell()
            }
            
            cell.titleLabel.text = movie.title
            cell.releaseDateLabel.text = Util.formatReleaseDate(dateString: movie.releaseDate)
            
            let rating = (movie.voteAverage * 10).rounded() / 10
            cell.ratingLabel.text = "\(rating)/10"
            cell.ratingProgressView.progress = Float(movie.voteAverage / 10)
            
            // pull poster from cache if already downloaded
            if let image = imageCache.object(forKey: movie.id as NSNumber) {
                cell.largePosterImageView.image = image
            } else if let posterPath = movie.posterPath {
                Task {
                    do {
                        // attempt to fetch poster here as well, in case the image hadn't finished downloading yet
                        if let image = try await fetcher.getMoviePoster(posterPath: posterPath) {
                            imageCache.setObject(image, forKey: movie.id as NSNumber)
                            cell.largePosterImageView.image = image
                        }
                    } catch {
                        Util.showErrorAlert(vc: self, error: error)
                    }
                }
            }
            return cell
        } else {
            guard let cell = tableView.dequeueReusableCell(withIdentifier: "movieOverviewCell", for: indexPath) as? MovieOverviewCell else {
                print("Failed to initialize MovieOverviewCell, returning empty cell")
                return UITableViewCell()
            }
            cell.overviewLabel.text = !movie.overview.isEmpty ? movie.overview : "No overview available."
            return cell
        }
    }
    
    // specify heights to avoid constraint warnings
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return indexPath.row == 0 ? 155 : UITableView.automaticDimension
    }
}
