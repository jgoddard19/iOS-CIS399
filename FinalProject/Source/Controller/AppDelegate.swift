//
//  AppDelegate.swift
//  FinalProject
//
//  Created by Jared Goddard on 8/1/15.
//
//

import CoreDataService
import UIKit


@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
        CoreDataService.storeName = "FinalProject"
        CoreDataService.dataInitializer = FinalProjectDataInitializer()
        CoreDataService.sharedCoreDataService
        
        return true
    }
    
    // MARK: Properties
    var window: UIWindow?
}


