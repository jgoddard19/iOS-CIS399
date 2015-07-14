//
//  AppDelegate.swift
//  FinalProject
//
//  Created by Charles Augustine.
//
//


import CoreDataService
import UIKit


@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
	func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
		CoreDataService.storeName = "FinalProject"
		// The following line of code can be used to provide a data initializer to setup initial data in CoreData
//		CoreDataService.dataInitializer = <#Data Initializer Instance#>
		CoreDataService.sharedCoreDataService

		return true
	}

	// MARK: Properties
	var window: UIWindow?
}

