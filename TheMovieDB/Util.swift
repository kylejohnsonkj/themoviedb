//
//  Util.swift
//  TheMovieDB
//
//  Created by Kyle Johnson on 7/10/23.
//

import Foundation
import UIKit

class Util {
    private static func formatDate(from dateString: String, outputFormat: String) -> String? {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        
        guard let date = dateFormatter.date(from: dateString) else {
            return nil
        }
        dateFormatter.dateFormat = outputFormat
        return dateFormatter.string(from: date)
    }
    
    static func formatYear(dateString: String) -> String? {
        return formatDate(from: dateString, outputFormat: "yyyy")
    }
    
    static func formatReleaseDate(dateString: String) -> String? {
        return formatDate(from: dateString, outputFormat: "MMMM d, yyyy")
    }
    
    @MainActor
    static func showErrorAlert(vc: UIViewController, error: Error) {
        let alert = UIAlertController(title: "Fetch Error", message: error.localizedDescription, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        vc.present(alert, animated: true)
    }
}
