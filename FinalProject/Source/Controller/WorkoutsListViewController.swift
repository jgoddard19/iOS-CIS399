//
//  WorkoutsListViewController.swift
//  FinalProject
//
//  Created by Jared Goddard on 7/30/15.
//
//

import CoreData
import CoreDataService
import UIKit

class WorkoutsListViewController: UITableViewController, UIAlertViewDelegate, NSFetchedResultsControllerDelegate {
    
    var day: String?
    
    // MARK: Properties
    var workouts = Array<String>() {
        didSet {
            if(self.isViewLoaded()) {
                workoutsListTable.reloadData()
            }
        }
    }
    
    // MARK: IBAction
    @IBAction private func edit(sender: AnyObject) {
        workoutsListTable.setEditing(true, animated: true)
        
        navigationItem.setLeftBarButtonItem(doneButton, animated: true)
    }
    
    @IBAction private func done(sender: AnyObject) {
        workoutsListTable.setEditing(false, animated: true)
        //horizontalSwipeToEditMode = false
        
        navigationItem.setLeftBarButtonItem(editButton, animated: true)
    }
    
    @IBAction private func addWorkout(sender: AnyObject) {
        addingNewWorkout = true
        
//        presentNameWorkoutAlert()
    }
    
    // MARK: UITableView
    func tableView(workoutsView: UITableView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("WorkoutCell", forIndexPath: indexPath) as! UITableViewCell
        //cell.textLabel?.text = UITableViewCell(named: workouts[indexPath.item])
        
        return cell
    }
    
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        let result: Int
        
        if let someSections = workoutResultsController?.sections {
            result = someSections.count
        }
        else {
            result = 0
        }
        
        return result
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let result: Int
        
        if let someSectionInfo = workoutResultsController?.sections?[section] as? NSFetchedResultsSectionInfo {
            result = someSectionInfo.numberOfObjects
        }
        else {
            result = 0
        }
        
        return result
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("WorkoutCell", forIndexPath: indexPath) as! UITableViewCell
        if let someWorkout = workoutResultsController?.objectAtIndexPath(indexPath) as? Workout {
            cell.textLabel!.text = someWorkout.workoutName
        }
        
        return cell
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
    
        if workoutsListTable.editing && !horizontalSwipeToEditMode {
            workoutIndexForRename = indexPath.row
            
            addingNewWorkout = false
//            presentNameWorkoutAlert()
        }
        else {
            performSegueWithIdentifier("LiftsViewSegue", sender: self)
        }
    }
    
    override func tableView(tableView: UITableView, willBeginEditingRowAtIndexPath indexPath: NSIndexPath) {
        navigationItem.setLeftBarButtonItem(doneButton, animated: true)
        
        horizontalSwipeToEditMode = true
    }
    
    override func tableView(tableView: UITableView, didEndEditingRowAtIndexPath indexPath: NSIndexPath) {
        navigationItem.setLeftBarButtonItem(editButton, animated: true)
        
        horizontalSwipeToEditMode = false
    }
    
    /*
    
    override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        if editingStyle == .Delete {
            var workoutsToReindex: Array<Workout>?
            let numberOfRows = workoutsListTable.numberOfRowsInSection(0)
            if indexPath.row + 1 < numberOfRows {
                if let workouts = workoutResultsController?.fetchedObjects as? Array<Workout> {
                    let reindexRange = NSMakeRange(indexPath.row + 1, numberOfRows - (indexPath.row + 1))
                    workoutsToReindex = ((workouts as NSArray).subarrayWithRange(reindexRange)) as? Array<Workout>
                }
            }
            
            if let workout = workoutResultsController?.objectAtIndexPath(indexPath) as? Workout {
                FinalProjectDAO.sharedFinalProjectDAO.deleteWorkout(workout, withSaveCompletionHandler: { (success, error) -> Void in
                    if success {
                        if let someWorkouts = workoutsToReindex {
                            FinalProjectDAO.sharedFinalProjectDAO.reindexWorkouts(someWorkouts, shiftForward: false)
                        }
                    }
                    else {
                        println("Error deleting workout: \(error)")
                    }
                })
            }
        }
    }
    
    override func tableView(tableView: UITableView, titleForDeleteConfirmationButtonForRowAtIndexPath indexPath: NSIndexPath) -> String! {
        return "Delete"
    }
    
    // MARK: UIAlertViewDelegate
    func alertView(alertView: UIAlertView, willDismissWithButtonIndex buttonIndex: Int) {
        if !addingNewWorkout {
            if let selectedIndexPath = workoutsListTable.indexPathForSelectedRow() {
                workoutsListTable.deselectRowAtIndexPath(selectedIndexPath, animated: true)
            }
        }
    }
    
    func alertView(alertView: UIAlertView, didDismissWithButtonIndex buttonIndex: Int) {
        if buttonIndex != alertView.cancelButtonIndex {
            let workoutNameField = alertView.textFieldAtIndex(0)!
            if addingNewWorkout {
                FinalProjectDAO.sharedFinalProjectDAO.addWorkoutWithName(workoutNameField.text, andOrderIndex: workoutsListTable.numberOfRowsInSection(0))
            }
            else {
                if let row = workoutIndexForRename, let workout = workoutResultsController?.objectAtIndexPath(NSIndexPath(forRow: row, inSection: 0)) as? Workout {
                    FinalProjectDAO.sharedFinalProjectDAO.renameWorkout(workout, withNewName: workoutNameField.text)
                }
            }
        }
        
        addingNewWorkout = false;
        workoutIndexForRename = nil;
    }
    
    // MARK: UITextFieldDelegate
    func textFieldShouldClear(textField: UITextField) -> Bool {
        return true
    }
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        if let alertView = workoutNameAlertView {
            alertView.dismissWithClickedButtonIndex(alertView.firstOtherButtonIndex, animated: true)
        }
        
        return false
    }
    
    // MARK: Private
    private func presentNameWorkoutAlert() {
        let title: String
        // let time:
        let message: String
        let initialText: String
        if addingNewWorkout {
            title = "Add Workout"
            message = "Name your Workout:"
            initialText = ""
            //message = "Set workout time:"
        }
        else {
            title = "Rename Workout"
            message = "Rename your Workout:"
            
            if let item = workoutIndexForRename, someWorkout = workoutResultsController?.objectAtIndexPath(NSIndexPath(forItem: item, inSection: 0)) as? Workout {
                initialText = someWorkout.workoutName
            }
            else {
                initialText = ""
            }
        }
        
        let alertView = UIAlertView(title: title, message: message, delegate: self, cancelButtonTitle: "Cancel", otherButtonTitles: "Done")
        alertView.alertViewStyle = .PlainTextInput
        
        if let textField = alertView.textFieldAtIndex(0) {
            textField.clearButtonMode = .Always
            textField.placeholder = "Workout Name"
            textField.returnKeyType = .Done
//            textField.delegate = self
        }
        
        alertView.show()
        workoutNameAlertView = alertView
    }

    */
    
    private func updateUIForSelectedDay() {
        if let someDay = selectedDay {
            navigationItem.title = someDay.dayName
        }
        
        setupResultsController()
    }
    
    private func setupResultsController() {
        if let resultsController = FinalProjectDAO.sharedFinalProjectDAO.fetchedResultsControllerForWorkoutList() {
            resultsController.delegate = self
            workoutResultsController = resultsController
        }
        else {
            workoutResultsController = nil
        }
        
        workoutsListTable.reloadData()
    }
    
    private func unregisterForNotifications() {
        if let someToken: AnyObject = initializationFinishedToken {
            NSNotificationCenter.defaultCenter().removeObserver(someToken)
            initializationFinishedToken = nil
        }
    }
    
    /*
    
    // MARK: View Management
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        switch segue.identifier {
        case .Some("LiftsViewSegue"):
            if let indexPath = workoutsListTable.indexPathForSelectedRow(), let selectedWorkout = workoutResultsController?.objectAtIndexPath(indexPath) as? Workout {
                let workoutsListViewController = segue.destinationViewController as! AddLiftViewController
                workoutsListViewController.selectedWorkout = selectedWorkout
                
                workoutsListTable.deselectRowAtIndexPath(indexPath, animated: true)
            }
        default:
            super.prepareForSegue(segue, sender: sender)
        }
    }

    */
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.setLeftBarButtonItem(editButton, animated: false)
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    override func viewDidDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
    }
    
    // MARK: Properties
    var selectedDay: Day! {
        didSet {
            if isViewLoaded() {
                updateUIForSelectedDay()
            }
        }
    }
    
    // MARK: Deinitialization
    deinit {
        unregisterForNotifications()
    }
    
    private var horizontalSwipeToEditMode = false
    private var addingNewWorkout = false
    private var workoutIndexForRename: Int?
    private weak var workoutNameAlertView: UIAlertView?
    private var initializationFinishedToken: AnyObject?
    private var workoutResultsController: NSFetchedResultsController?
    @IBOutlet weak var workoutsListViewTitle: UINavigationItem!
    @IBOutlet private var doneButton: UIBarButtonItem!
    @IBOutlet private var editButton: UIBarButtonItem!
    @IBOutlet weak var workoutsListTable: UITableView!

}