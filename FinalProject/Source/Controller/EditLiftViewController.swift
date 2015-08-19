//
//  EditLiftViewController.swift
//  FinalProject
//
//  Created by Jared Goddard on 8/12/15.
//
//

import Foundation
import UIKit
import CoreData
import CoreDataService

class EditLiftViewController: UIViewController, UITextFieldDelegate, NSFetchedResultsControllerDelegate {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationItem.hidesBackButton = true
        updateUIForSelectedLift()
    }
    
    @IBAction private func done(sender: AnyObject) {
        //self.navigationItem.hidesBackButton = false
        if repsPerSetTextField.text != "" && setsTextField.text != "" && liftNameTextField.text != "" {
            if let someLift = selectedLift {
                FinalProjectDAO.sharedFinalProjectDAO.updateLift(someLift, withNewName: liftNameTextField.text, andNewSets: setsTextField.text.toInt()!, andNewRepsPerSet: repsPerSetTextField.text.toInt()!)
            }
        }
        else {
            var alert = UIAlertView()
            alert.title = "Why would you take that out? All fields are required"
            alert.addButtonWithTitle("Reevaluate bad choices")
            alert.show()
            return
        }
        navigationController?.popViewControllerAnimated(true)
    }
    
    private func updateUIForSelectedLift() {
        if let someLift = selectedLift {
            navigationItem.title = "Edit lift: \(someLift.liftName)"
            liftNameTextField.text = someLift.liftName
            setsTextField.text = someLift.sets.stringValue
            repsPerSetTextField.text = someLift.repsPerSet.stringValue
            textFieldShouldReturn(liftNameTextField)
            textFieldShouldReturn(setsTextField)
            textFieldShouldReturn(repsPerSetTextField)
        }
    }
    
    // MARK: UITextFieldDelegate
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        return true
    }
    
    //someLift.liftName = liftNameTextField.text
    
    // MARK: Properties
    var selectedLift: Lift! {
        didSet {
            if isViewLoaded() {
                updateUIForSelectedLift()
            }
        }
    }
    
    @IBOutlet weak var repsPerSetTextField: UITextField!
    @IBOutlet weak var setsTextField: UITextField!
    @IBOutlet weak var liftNameTextField: UITextField!
    @IBOutlet weak var doneButton: UIBarButtonItem!
}