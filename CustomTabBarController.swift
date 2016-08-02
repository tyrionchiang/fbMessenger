//
//  CustomTabBarController.swift
//  fbMessenger
//
//  Created by Chiang Chuan on 8/1/16.
//  Copyright © 2016 Chiang Chuan. All rights reserved.
//

import UIKit

class CustomTabBarController: UITabBarController{
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let layout = UICollectionViewFlowLayout()
        let friendsController = FriendsController(collectionViewLayout: layout)
        let recentMessageNavController = UINavigationController(rootViewController: friendsController)
        recentMessageNavController.tabBarItem.title = "Recent"
        recentMessageNavController.tabBarItem.image =  UIImage(named: "recent")
        
        
        viewControllers = [recentMessageNavController, createDummyNavControllerWithTitle("Calls", imageName: "calls"), createDummyNavControllerWithTitle("Groups", imageName: "groups"), createDummyNavControllerWithTitle("People", imageName: "people"), createDummyNavControllerWithTitle("Settings", imageName: "settings")]
        
    }
    
    private func createDummyNavControllerWithTitle(title: String, imageName: String) -> UINavigationController{
        let viewController = UIViewController()
        let navController = UINavigationController(rootViewController: viewController)
        navController.tabBarItem.title = title
        navController.tabBarItem.image = UIImage(named: imageName)
        
        return navController
    }
    
    
}
