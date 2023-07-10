//
//  Util.swift
//  TheMovieDB
//
//  Created by Kyle Johnson on 7/10/23.
//

import Foundation

class DateUtils {
    static func formatYear(from dateString: String) -> String? {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        
        if let date = dateFormatter.date(from: dateString) {
            let yearFormatter = DateFormatter()
            yearFormatter.dateFormat = "yyyy"
            return yearFormatter.string(from: date)
        } else {
            return nil
        }
    }
}
