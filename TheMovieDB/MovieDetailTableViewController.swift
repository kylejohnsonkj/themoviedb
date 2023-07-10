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
            cell.ratingLabel.text = "\(Util.roundToNearestTenth(number: movie.voteAverage))/10"
            cell.ratingProgressView.progress = Float(movie.voteAverage / 10)
            
            // we want to fetch on the detail screen as well, in case the image hadn't finished fetching yet
            if let image = imageCache.object(forKey: movie.id as NSNumber) {
                cell.largePosterImageView.image = image
            } else if let posterPath = movie.posterPath {
                Task {
                    if let image = try await fetcher.fetchMoviePoster(posterPath: posterPath) {
                        imageCache.setObject(image, forKey: movie.id as NSNumber)
                        await MainActor.run {
                            cell.largePosterImageView.image = image
                        }
                    }
                }
            }
            return cell
        } else {
            guard let cell = tableView.dequeueReusableCell(withIdentifier: "movieOverviewCell", for: indexPath) as? MovieOverviewCell else {
                print("Failed to initialize MovieOverviewCell, returning empty cell")
                return UITableViewCell()
            }
            cell.overviewLabel.text = movie.overview
            return cell
        }
    }
}
