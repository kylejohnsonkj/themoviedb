//
//  Util.swift
//  TheMovieDB
//
//  Created by Kyle Johnson on 7/10/23.
//

import Foundation

class Util {
    static func formatYear(from dateString: String) -> String? {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        
        if let date = dateFormatter.date(from: dateString) {
            dateFormatter.dateFormat = "yyyy"
            return dateFormatter.string(from: date)
        } else {
            return nil
        }
    }
    
    static func formatReleaseDate(dateString: String) -> String? {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        
        if let date = dateFormatter.date(from: dateString) {
            dateFormatter.dateFormat = "MMMM dd, yyyy"
            return dateFormatter.string(from: date)
        } else {
            return nil
        }
    }
    
    static func roundToNearestTenth(number: Double) -> Double {
        return (number * 10).rounded() / 10
    }
}
