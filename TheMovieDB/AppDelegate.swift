//
//  AppDelegate.swift
//  TheMovieDB
//
//  Created by Kyle Johnson on 7/10/23.
//

import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    static let TMDB_API_KEY = "<TMDB_API_KEY_HERE>"
    
    var window: UIWindow?
    
    static var imageCache = NSCache<NSNumber, UIImage>()

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        return true
    }

}

