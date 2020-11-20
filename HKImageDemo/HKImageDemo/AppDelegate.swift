//
//  AppDelegate.swift
//  HKImageDemo
//
//  Created by 김승한 on 2020/11/17.
//

import UIKit

@main
class AppDelegate: UIResponder, UIApplicationDelegate {
    var window: UIWindow?
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        self.window?.tintColor = UIColor(named: "mainTintColor")
        
        self.initialRoute()
        
        return true
    }
    
    func initialRoute() {
        if let navigationController = self.window?.rootViewController as? UINavigationController {
            UnsplashInitialRouter(with: navigationController).showMainList()
        } else {
            fatalError("Root window doesn't have 'UINavigationController'")
        }
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        
    }
    
    func applicationWillResignActive(_ application: UIApplication) {
        
    }
    
    func applicationWillTerminate(_ application: UIApplication) {
        
    }
    
    func applicationDidEnterBackground(_ application: UIApplication) {
        
    }
    
    func applicationWillEnterForeground(_ application: UIApplication) {
        
    }
}

