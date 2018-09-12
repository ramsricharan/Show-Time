//
//  CustomTabBarController.swift
//  Show time
//
//  Created by Ram Sri Charan on 4/17/18.
//  Copyright © 2018 Ram Sri Charan. All rights reserved.
//

import UIKit

class CustomTabBarController: UITabBarController {

    override func viewDidLoad() {
        super.viewDidLoad()

        tabBar.tintColor = UIColor.white
        tabBar.barTintColor = UIColor.red
        
        
        
        // Initiate First tab
        let NowPlayingViewController = MasterTableViewController()
        NowPlayingViewController.MovieListURL = "http://api.themoviedb.org/3/movie/now_playing?api_key=606a18ba03513c0c982f6120e7d4b305"
        NowPlayingViewController.MovieListType = "API"
        let nowPlayingTab = UINavigationController(rootViewController: NowPlayingViewController)
        nowPlayingTab.tabBarItem.title = "Now Playing"
        nowPlayingTab.tabBarItem.image = #imageLiteral(resourceName: "now_playing")
        
        // Popular movies tab
        let PopularMoviesController = MasterTableViewController()
        PopularMoviesController.MovieListURL = "http://api.themoviedb.org/3/movie/popular?api_key=606a18ba03513c0c982f6120e7d4b305"
        PopularMoviesController.MovieListType = "API"
        let popularMoviesTab = UINavigationController(rootViewController: PopularMoviesController)
        popularMoviesTab.tabBarItem.title = "Popular"
        popularMoviesTab.tabBarItem.image = #imageLiteral(resourceName: "popular")
        
        
        // Upcoming movies tab
        let UpcomingMoviesController = MasterTableViewController()
        UpcomingMoviesController.MovieListURL = "http://api.themoviedb.org/3/movie/upcoming?api_key=606a18ba03513c0c982f6120e7d4b305"
        UpcomingMoviesController.MovieListType = "API"
        let upcomingMoviesTab = UINavigationController(rootViewController: UpcomingMoviesController)
        upcomingMoviesTab.tabBarItem.title = "Upcoming"
        upcomingMoviesTab.tabBarItem.image = #imageLiteral(resourceName: "upcoming")
        
        
        // Favorite Movies tab
        let FavoriteMoviesController = MasterTableViewController()
        FavoriteMoviesController.MovieListType = "FAV"
        let favMovieTab = UINavigationController(rootViewController: FavoriteMoviesController)
        favMovieTab.tabBarItem.title = "Favorites"
        favMovieTab.tabBarItem.image = #imageLiteral(resourceName: "favorite")
        
        
        viewControllers = [nowPlayingTab, popularMoviesTab, upcomingMoviesTab, favMovieTab]
    }
    


}
