//
//  MainTabBarController.swift
//  Anime
//
//  Created by elene malakmadze on 10.02.26.
//

import UIKit

final class MainTabBarController: UITabBarController {

    override func viewDidLoad() {
        super.viewDidLoad()
        setupTabs()

    }

    private func setupTabs() {
        let discoverVC = createNavController(
            rootViewController: DiscoverViewController(),
            title: "Discover",
            image: UIImage(systemName: "magnifyingglass"),
            selectedImage: UIImage(systemName: "magnifyingglass")
        )

        let seasonalVC = createNavController(
            rootViewController: SeasonalViewController(),
            title: "Seasonal",
            image: UIImage(systemName: "calendar"),
            selectedImage: UIImage(systemName: "calendar.circle.fill")
        )

        let myListVC = createNavController(
            rootViewController: FavouritesViewController(),
            title: "Favourites",
            image: UIImage(systemName: "heart"),
            selectedImage: UIImage(systemName: "heart.fill")
        )
//
//        let gamesVC = createNavController(
//            rootViewController: GamesViewController(),
//            title: "Games",
//            image: UIImage(systemName: "gamecontroller"),
//            selectedImage: UIImage(systemName: "gamecontroller.fill")
//        )

        let profileVC = createNavController(
            rootViewController: ProfileViewController(),
            title: "Profile",
            image: UIImage(systemName: "person"),
            selectedImage: UIImage(systemName: "person.fill")
        )

        viewControllers = [discoverVC, seasonalVC, myListVC, profileVC]
    }

    private func createNavController(
        rootViewController: UIViewController,
        title: String,
        image: UIImage?,
        selectedImage: UIImage?
    ) -> UINavigationController {
        let navController = UINavigationController(rootViewController: rootViewController)
        navController.tabBarItem = UITabBarItem(title: title, image: image, selectedImage: selectedImage)
        rootViewController.navigationItem.title = title
        return navController
    }
}

