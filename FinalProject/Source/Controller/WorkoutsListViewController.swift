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

class WorkoutsListViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, UIAlertViewDelegate, UITextViewDelegate, NSFetchedResultsControllerDelegate {
    
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
        
        toolBar.setItems([doneButton], animated: false)
    }
    
    @IBAction private func done(sender: AnyObject) {
        workoutsListTable.setEditing(false, animated: true)
        
        toolBar.setItems([editButton], animated: false)
    }
    
    @IBAction private func addWorkout(sender: AnyObject) {
        addingNewWorkout = true
        
        addNewWorkoutAlert()
        workoutsListTable.reloadData()
    }
    
    // MARK: UITableView
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        let result: Int
        
        if let someSections = workoutResultsController?.sections {
            result = someSections.count
        }
        else {
            result = 0
        }
        
        return result
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let result: Int
        
        if let someSectionInfo = workoutResultsController?.sections?[section] as? NSFetchedResultsSectionInfo {
            result = someSectionInfo.numberOfObjects
        }
        else {
            result = 0
        }
        
        return result
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("WorkoutCell", forIndexPath: indexPath) as! UITableViewCell
        if let someWorkout = workoutResultsController?.objectAtIndexPath(indexPath) as? Workout {
            cell.textLabel!.text = someWorkout.workoutName
        }
        
        return cell
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
    
        if workoutsListTable.editing {
            workoutIndexForRename = indexPath.row
            
            addingNewWorkout = false
            addNewWorkoutAlert()
        }
        else {
            performSegueWithIdentifier("LiftsViewSegue", sender: self)
        }
    }
    
    func tableView(tableView: UITableView, willBeginEditingRowAtIndexPath indexPath: NSIndexPath) {
        toolBar.setItems([doneButton], animated: true)
    }
    
    func tableView(tableView: UITableView, didEndEditingRowAtIndexPath indexPath: NSIndexPath) {
        toolBar.setItems([editButton], animated: true)
    }
    
    
    
    func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
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
                        
                    }
                    else {
                        println("Error deleting workout: \(error)")
                    }
                })
            }
        }
    }
    
    func tableView(tableView: UITableView, titleForDeleteConfirmationButtonForRowAtIndexPath indexPath: NSIndexPath) -> String! {
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
                FinalProjectDAO.sharedFinalProjectDAO.addWorkoutWithName(workoutNameField.text, inDay: selectedDay)
            }
//            else {
//                if let row = workoutIndexForRename, let workout = workoutResultsController?.objectAtIndexPath(NSIndexPath(forRow: row, inSection: 0)) as? Workout {
//                    FinalProjectDAO.sharedFinalProjectDAO.renameWorkout(workout, withNewName: workoutNameField.text)
//                }
//            }
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
    
    // MARK: NSFetchedResultsControllerDelegate
    func controllerWillChangeContent(controller: NSFetchedResultsController) {
        if !ignoreUpdates {
            workoutsListTable.beginUpdates()
        }
    }
    
    func controller(controller: NSFetchedResultsController, didChangeObject anObject: AnyObject, atIndexPath indexPath: NSIndexPath?, forChangeType type: NSFetchedResultsChangeType, newIndexPath: NSIndexPath?) {
        if !ignoreUpdates {
            switch type {
            case .Delete:
                workoutsListTable.deleteRowsAtIndexPaths([indexPath!], withRowAnimation: .Left)
            case .Insert:
                workoutsListTable.insertRowsAtIndexPaths([newIndexPath!], withRowAnimation: .Left)
            case .Update:
                if let cell = workoutsListTable.cellForRowAtIndexPath(indexPath!), let workout = anObject as? Workout {
                    cell.textLabel!.text = workout.workoutName
                }
            default:
                break
            }
        }
    }
    
    func controller(controller: NSFetchedResultsController, didChangeSection sectionInfo: NSFetchedResultsSectionInfo, atIndex sectionIndex: Int, forChangeType type: NSFetchedResultsChangeType) {
        if !ignoreUpdates {
            switch type {
            case .Delete:
                workoutsListTable.deleteSections(NSIndexSet(index: sectionIndex), withRowAnimation: .Left)
            case .Insert:
                workoutsListTable.insertSections(NSIndexSet(index: sectionIndex), withRowAnimation: .Left)
            default:
                println("Unexpected change type in controller:didChangeSection:atIndex:forChangeType:")
            }
        }
    }
    
    func controllerDidChangeContent(controller: NSFetchedResultsController) {
        if !ignoreUpdates {
            workoutsListTable.endUpdates()
        }
    }
    
    // MARK: Private
    private func addNewWorkoutAlert() {
        let title: String
        // let time:
        let message: String
        let initialText: String
//        if addingNewWorkout {
            title = "Add Workout"
            message = "Name your Workout:"
            initialText = ""
            //message = "Set workout time:"
//        }
//        else {
//            title = "Rename Workout"
//            message = "Rename your Workout:"
//            
//            if let item = workoutIndexForRename, someWorkout = workoutResultsController?.objectAtIndexPath(NSIndexPath(forItem: item, inSection: 0)) as? Workout {
//                initialText = someWorkout.workoutName
//            }
//            else {
//                initialText = ""
//            }
//        }
        
        let alertView = UIAlertView(title: title, message: message, delegate: self, cancelButtonTitle: "Cancel", otherButtonTitles: "Done")
        alertView.alertViewStyle = .PlainTextInput
        
        if let textField = alertView.textFieldAtIndex(0) {
            textField.clearButtonMode = .Always
            textField.placeholder = "Workout Name"
            textField.returnKeyType = .Done
            //textField.delegate = self
        }
        
        alertView.show()
        workoutNameAlertView = alertView
    }
    
//    func textFieldShouldClear(textField: UITextField) -> Bool {
//        return true
//    }
//    
//    func textFieldShouldReturn(textField: UITextField) -> Bool {
//        if let alertView = workoutNameAlertView {
//            alertView.dismissWithClickedButtonIndex(alertView.firstOtherButtonIndex, animated: true)
//        }
//        
//        return false
//    }
    
    private func updateUIForSelectedDay() {
        if let someDay = selectedDay {
            navigationItem.title = "\(someDay.dayName) workouts"
        }
        
        setupResultsController()
    }
    
    private func setupResultsController() {
        if let someDay = selectedDay, let resultsController = FinalProjectDAO.sharedFinalProjectDAO.fetchedResultsControllerForWorkoutInDay(someDay) {
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
    
//    // MARK: View Management
//    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
//        switch segue.identifier {
//        case .Some("WorkoutSelectedSegue"):
//            if let indexPath = workoutsListTable.indexPathForSelectedRow(), let selectedWorkout = workoutResultsController?.objectAtIndexPath(indexPath) as? Workout {
//                let workoutsListViewController = segue.destinationViewController as! AddLiftViewController
//                workoutsListViewController.selectedWorkout = selectedWorkout
//                
//                workoutsListTable.deselectRowAtIndexPath(indexPath, animated: true)
//            }
//        default:
//            super.prepareForSegue(segue, sender: sender)
//        }
//    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        toolBar.setItems([editButton], animated: false)
        
        let userDefaults = NSUserDefaults.standardUserDefaults()
        
        updateUIForSelectedDay()
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
    
    private var addingNewWorkout = false
    private var ignoreUpdates = false
    private var workoutIndexForRename: Int?
    private weak var workoutNameAlertView: UIAlertView?
    private var initializationFinishedToken: AnyObject?
    private var workoutResultsController: NSFetchedResultsController?
    @IBOutlet weak var toolBar: UIToolbar!
    @IBOutlet private var doneButton: UIBarButtonItem!
    @IBOutlet private var editButton: UIBarButtonItem!
    @IBOutlet weak var workoutsListTable: UITableView!

}