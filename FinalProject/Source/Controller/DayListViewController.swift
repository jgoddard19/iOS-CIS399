//
//  DayListViewController.swift
//  FinalProject
//
//  Created by Jared Goddard on 7/29/15.
//
//

import Foundation
import UIKit
import CoreData
import CoreDataService

class DayListViewController: UITableViewController, UITableViewDataSource, UITableViewDelegate, NSFetchedResultsControllerDelegate {
    
    var titleLabel: String?
    
    
    // MARK: UITableView
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        let result: Int
        
        if let someSections = dayListResultsController?.sections {
            result = someSections.count
        }
        else {
            result = 0
        }
        
        return result
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let result: Int
        
        if let someSectionInfo = dayListResultsController?.sections?[section] as? NSFetchedResultsSectionInfo {
            result = someSectionInfo.numberOfObjects
        }
        else {
            result = 0
        }
        
        return result
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        //performSegueWithIdentifier("DaySelectedSegue", sender: self)
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        switch segue.identifier {
        case .Some("DaySelectedSegue"):
            if let indexPath = daysTable.indexPathForSelectedRow(), let selectedDay = dayListResultsController?.objectAtIndexPath(indexPath) as? Day {
                let workoutsListViewController = segue.destinationViewController as! WorkoutsListViewController
                workoutsListViewController.selectedDay = selectedDay
                
                daysTable.deselectRowAtIndexPath(indexPath, animated: true)
            }
        default:
            super.prepareForSegue(segue, sender: sender)
        }
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("DayCell", forIndexPath: indexPath) as! UITableViewCell
        if let someDay = dayListResultsController?.objectAtIndexPath(indexPath) as? Day {
            cell.textLabel!.text = someDay.dayName
        }
        
        return cell
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    override func viewDidDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
    }
    
    private func setupResultsController() {
        if let resultsController = FinalProjectDAO.sharedFinalProjectDAO.fetchedResultsControllerForDayList() {
            resultsController.delegate = self
            dayListResultsController = resultsController
        }
        else {
            dayListResultsController = nil
        }
        
        daysTable.reloadData()
    }
    
    private func unregisterForNotifications() {
        if let someToken: AnyObject = initializationFinishedToken {
            NSNotificationCenter.defaultCenter().removeObserver(someToken)
            initializationFinishedToken = nil
        }
    }
    
    // MARK: View Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if CoreDataService.sharedCoreDataService.initializationFinished {
            setupResultsController()
        }
        else if initializationFinishedToken == nil {
            initializationFinishedToken = NSNotificationCenter.defaultCenter().addObserverForName(CoreDataServiceInitializationFinishedNotification, object: nil, queue: NSOperationQueue.mainQueue(), usingBlock: { [unowned self] (notification) -> Void in
                self.setupResultsController()
                self.unregisterForNotifications()
            })
        }
    }
    
    // MARK: Deinitialization
    deinit {
        unregisterForNotifications()
    }
    
    private var dayListResultsController: NSFetchedResultsController?
    private var initializationFinishedToken: AnyObject?
    @IBOutlet private weak var daysTable: UITableView!
    
}