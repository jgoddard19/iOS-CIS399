//
//  LiftsViewController.swift
//  FinalProject
//
//  Created by Jared Goddard on 8/10/15.
//
//

import CoreData
import CoreDataService
import UIKit

class LiftsViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, NSFetchedResultsControllerDelegate {
    
    private func updateUIForSelectedWorkout() {
        if let someWorkout = selectedWorkout {
            navigationItem.title = "Lifts for \(someWorkout.workoutName)"
        }
        
        setupResultsController()
    }
    
    private func setupResultsController() {
        if let someWorkout = selectedWorkout, let resultsController = FinalProjectDAO.sharedFinalProjectDAO.fetchedResultsControllerForLiftInWorkout(someWorkout) {
            resultsController.delegate = self
            liftResultsController = resultsController
        }
        else {
            liftResultsController = nil
        }
        liftsTable.reloadData()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let result: Int
        
        if let someSectionInfo = liftResultsController?.sections?[section] as? NSFetchedResultsSectionInfo {
            result = someSectionInfo.numberOfObjects
        }
        else {
            result = 0
        }
        
        return result
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("LiftCell", forIndexPath: indexPath) as! UITableViewCell
        if let someLift = liftResultsController?.objectAtIndexPath(indexPath) as? Lift {
            cell.textLabel!.text = someLift.liftName
        }
        
        return cell
    }
    
    // MARK: Properties
    var selectedWorkout: Workout! {
        didSet {
            if isViewLoaded() {
                updateUIForSelectedWorkout()
            }
        }
    }
    
    @IBOutlet weak var doneButton: UIBarButtonItem!
    @IBOutlet weak var editButton: UIBarButtonItem!
    @IBOutlet weak var addLiftsButton: UIBarButtonItem!
    private var liftResultsController: NSFetchedResultsController?
    @IBOutlet weak var liftsTable: UITableView!
    
}
