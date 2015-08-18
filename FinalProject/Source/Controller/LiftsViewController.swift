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

class LiftsViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, UITextFieldDelegate, NSFetchedResultsControllerDelegate {
    
    // MARK: Properties
    var lifts = Array<String>() {
        didSet {
            if(self.isViewLoaded()) {
                liftsTable.reloadData()
            }
        }
    }
    
    // MARK: IBAction
    @IBAction private func edit(sender: AnyObject) {
        liftsTable.setEditing(true, animated: true)
        
        toolBar.setItems([doneButton], animated: false)
    }
    
    @IBAction private func done(sender: AnyObject) {
        liftsTable.setEditing(false, animated: true)
        
        toolBar.setItems([editButton], animated: false)
    }
    
    @IBAction func showActionSheetTapped(sender: AnyObject) {
        //Create the AlertController
        let addLiftAlertController: UIAlertController = UIAlertController(title: "Add lift", message: "Enter lift info", preferredStyle: UIAlertControllerStyle.Alert)
        
        //Create and add the Cancel action
        let cancelAction: UIAlertAction = UIAlertAction(title: "Cancel", style: .Cancel) { action -> Void in
        }
        addLiftAlertController.addAction(cancelAction)
        //Create and add Add Lift
        let addLiftAction = UIAlertAction(title: "Add Lift", style: .Default) { (_) in
            let liftNameTextField = addLiftAlertController.textFields![0] as! UITextField
            let liftSetsTextField = addLiftAlertController.textFields![1] as! UITextField
            let liftRepsPerSetTextField = addLiftAlertController.textFields![2] as! UITextField
            
            FinalProjectDAO.sharedFinalProjectDAO.addLiftWithName(liftNameTextField.text, andSets: liftSetsTextField.text.toInt()!, andRepsPerSet: liftRepsPerSetTextField.text.toInt()!, inWorkout: self.selectedWorkout)
        }
        addLiftAction.enabled = true
        addLiftAlertController.addAction(addLiftAction)
        
        //Add text boxes
        addLiftAlertController.addTextFieldWithConfigurationHandler { (textField) in
            textField.placeholder = "Lift Name"
            
            NSNotificationCenter.defaultCenter().addObserverForName(UITextFieldTextDidChangeNotification, object: textField, queue: NSOperationQueue.mainQueue()) { (notification) in
                addLiftAction.enabled = textField.text != ""
            }
        }
        
        addLiftAlertController.addTextFieldWithConfigurationHandler { (textField) in
            textField.placeholder = "Sets"
            textField.secureTextEntry = false
        }
        
        addLiftAlertController.addTextFieldWithConfigurationHandler { (textField) in
            textField.placeholder = "Reps per set"
            textField.secureTextEntry = false
        }
        
        //Present the AlertController
        self.presentViewController(addLiftAlertController, animated: true, completion: nil)
    }
    
    @IBAction private func back(segue: UIStoryboardSegue) {
    }
    
    // MARK: UITableView
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        let result: Int
        
        if let someSections = liftResultsController?.sections {
            result = someSections.count
        }
        else {
            result = 0
        }
        return result
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
    
    // MARK: View Management
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        switch segue.identifier {
        case .Some("LiftSelectedSegue"):
            if let indexPath = liftsTable.indexPathForSelectedRow(), let selectedLift = liftResultsController?.objectAtIndexPath(indexPath) as? Lift {
                let editliftViewController = segue.destinationViewController as! EditLiftViewController
                editliftViewController.selectedLift = selectedLift
                
                liftsTable.deselectRowAtIndexPath(indexPath, animated: true)
            }
        default:
            super.prepareForSegue(segue, sender: sender)
        }
    }
    
    // MARK: UITableViewDataSource
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
        liftsTable.deselectRowAtIndexPath(indexPath, animated: true)
        
        if !liftsTable.editing {
            liftIndexForView = indexPath.row
        }
    }
    
    
    // Functionality for deleting lifts
    func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        if editingStyle == .Delete {
            var liftsToReindex: Array<Lift>?
            let numberOfRows = liftsTable.numberOfRowsInSection(0)
            if indexPath.row + 1 < numberOfRows {
                if let lifts = liftResultsController?.fetchedObjects as? Array<Lift> {
                    let reindexRange = NSMakeRange(indexPath.row + 1, numberOfRows - (indexPath.row + 1))
                    liftsToReindex = ((lifts as NSArray).subarrayWithRange(reindexRange)) as? Array<Lift>
                }
            }
            
            if let lift = liftResultsController?.objectAtIndexPath(indexPath) as? Lift {
                FinalProjectDAO.sharedFinalProjectDAO.deleteLift(lift, withSaveCompletionHandler: { (success, error) -> Void in
                    if success {
                        
                    }
                    else {
                        println("Error deleting lift: \(error)")
                    }
                })
            }
        }
    }
    
    // Delete button text display
    func tableView(tableView: UITableView, titleForDeleteConfirmationButtonForRowAtIndexPath indexPath: NSIndexPath) -> String! {
        return "Delete"
    }
    
    // MARK: NSFetchedResultsControllerDelegate
    func controllerWillChangeContent(controller: NSFetchedResultsController) {
        if !ignoreUpdates {
            liftsTable.beginUpdates()
        }
    }
    
    func controller(controller: NSFetchedResultsController, didChangeObject anObject: AnyObject, atIndexPath indexPath: NSIndexPath?, forChangeType type: NSFetchedResultsChangeType, newIndexPath: NSIndexPath?) {
        if !ignoreUpdates {
            switch type {
            case .Delete:
                liftsTable.deleteRowsAtIndexPaths([indexPath!], withRowAnimation: .Left)
            case .Insert:
                liftsTable.insertRowsAtIndexPaths([newIndexPath!], withRowAnimation: .Left)
            case .Update:
                if let cell = liftsTable.cellForRowAtIndexPath(indexPath!), let lift = anObject as? Lift {
                    cell.textLabel!.text = lift.liftName
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
                liftsTable.deleteSections(NSIndexSet(index: sectionIndex), withRowAnimation: .Left)
            case .Insert:
                liftsTable.insertSections(NSIndexSet(index: sectionIndex), withRowAnimation: .Left)
            default:
                println("Unexpected change type in controller:didChangeSection:atIndex:forChangeType:")
            }
        }
    }
    
    func controllerDidChangeContent(controller: NSFetchedResultsController) {
        if !ignoreUpdates {
            liftsTable.endUpdates()
        }
    }
    
    // MARK: UIAlertViewDelegate
    
/*
    
    func alertView(alertView: UIAlertView, willDismissWithButtonIndex buttonIndex: Int) {
        if let selectedIndexPath = liftsTable.indexPathForSelectedRow() {
            liftsTable.deselectRowAtIndexPath(selectedIndexPath, animated: true)
        }
    }
    
    func alertView(alertView: UIAlertView, didDismissWithButtonIndex buttonIndex: Int) {
        let liftNameField = alertView.textFieldAtIndex(0)!
        let liftSetsField = alertView.textFieldAtIndex(1)!
        let liftRepsPerSetField = alertView.textFieldAtIndex(2)!
        if buttonIndex != alertView.cancelButtonIndex {
            FinalProjectDAO.sharedFinalProjectDAO.addLiftWithName(liftNameField.text, andSets: liftSetsField.text.toInt()!, andRepsPerSet: 5/*liftRepsPerSetField.text.toInt()!*/, inWorkout: selectedWorkout)
        }
    }
    
    // MARK: Private
    private func addLiftAlert() {
        let title: String
        let message: String
        let initialText: String
        title = "Add Lift"
        message = "Create new Lift:"
        initialText = ""
        
        let alertView = UIAlertView(title: title, message: message, delegate: self, cancelButtonTitle: "Cancel", otherButtonTitles: "Done")
        alertView.alertViewStyle = UIAlertViewStyle.PlainTextInput
        
        if let textField = alertView.textFieldAtIndex(0) {
            textField.clearButtonMode = .Always
            textField.placeholder = "Lift Name"
            textField.returnKeyType = .Next
            textField.delegate = self
        }
        if let textField = alertView.textFieldAtIndex(1) {
            textField.clearButtonMode = .Always
            textField.placeholder = "Sets"
            textField.returnKeyType = .Next
            textField.delegate = self
        }
        if let textField = alertView.textFieldAtIndex(2) {
            textField.secureTextEntry = false
            textField.clearButtonMode = .Always
            textField.placeholder = "Reps per set"
            textField.returnKeyType = .Done
            textField.delegate = self
        }
        
        alertView.show()
        liftNameAlertView = alertView
    }


*/
    
    // MARK: UITextFieldDelegate
    func textFieldShouldClear(textField: UITextField) -> Bool {
        return true
    }
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        if let alertView = liftNameAlertView {
            if textField.returnKeyType == .Next {
                alertView.textFieldAtIndex(2)!.becomeFirstResponder()
            }
            else {
                alertView.dismissWithClickedButtonIndex(alertView.firstOtherButtonIndex, animated: true)
            }
        }
        
        return false
    }
    
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
        
        toolBar.setItems([editButton], animated: false)
        
        let userDefaults = NSUserDefaults.standardUserDefaults()
        
        updateUIForSelectedWorkout()
    }
    
    override func viewDidAppear(animated: Bool) {
        liftsTable.reloadData()
    }
    
    // MARK: Properties
    var selectedWorkout: Workout! {
        didSet {
            if isViewLoaded() {
                updateUIForSelectedWorkout()
            }
        }
    }
    
    private weak var liftNameAlertView: UIAlertView?
    private var liftIndexForView: Int?
    private var ignoreUpdates = false
    @IBOutlet weak var addButton: UIBarButtonItem!
    @IBOutlet weak var toolBar: UIToolbar!
    @IBOutlet weak var doneButton: UIBarButtonItem!
    @IBOutlet weak var editButton: UIBarButtonItem!
    private var liftResultsController: NSFetchedResultsController?
    @IBOutlet weak var liftsTable: UITableView!
    
}
