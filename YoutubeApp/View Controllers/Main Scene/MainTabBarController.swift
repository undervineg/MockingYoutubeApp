//
//  MainTabBarController.swift
//  YoutubeApp
//
//  Created by 심승민 on 10/03/2019.
//  Copyright © 2019 심승민. All rights reserved.
//

import UIKit

final class MainTabBarController: UITabBarController {
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tabBar.tintColor = .darkGray
        
        let logo = UIBarButtonItem(image: UIImage(named: "youtube")?.withRenderingMode(.alwaysOriginal),
                                   style: .plain,
                                   target: self,
                                   action: #selector(goHome))
        navigationItem.setLeftBarButton(logo, animated: false)
        
        setupChildViewControllers()
    }
    
    @objc private func goHome() {
        selectedIndex = 0
    }
}

extension UIViewController {
    func configureTabBarItem(title: String, image: String, tag: Int) {
        tabBarItem = UITabBarItem(title: title,
                                  image: UIImage(named: image)?.withRenderingMode(.alwaysTemplate),
                                  tag: tag)
    }
}

extension UITabBarController {
    func updateInsets() {
        tabBar.items?.forEach {
            $0.titlePositionAdjustment = UIOffset(horizontal: 0, vertical: -4)
        }
    }
    
    func setupChildViewControllers() {
        let homeVC = HomeViewController(collectionViewLayout: UICollectionViewFlowLayout())
        let trendingVC = HomeViewController(collectionViewLayout: UICollectionViewFlowLayout())
        let subscriptionsVC = HomeViewController(collectionViewLayout: UICollectionViewFlowLayout())
        let accountVC = HomeViewController(collectionViewLayout: UICollectionViewFlowLayout())
        
        homeVC.configureTabBarItem(title: "홈", image: "home", tag: 0)
        trendingVC.configureTabBarItem(title: "인기", image: "trending", tag: 1)
        subscriptionsVC.configureTabBarItem(title: "구독", image: "subscriptions", tag: 2)
        accountVC.configureTabBarItem(title: "계정", image: "account", tag: 3)
        
        let childVCs = [homeVC, trendingVC, subscriptionsVC, accountVC]
        
        self.viewControllers = childVCs
        
        self.updateInsets()
    }
}
