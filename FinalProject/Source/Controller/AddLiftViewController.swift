//
//  AddLiftViewController.swift
//  FinalProject
//
//  Created by Jared Goddard on 8/4/15.
//
//

import Foundation
import UIKit

//NOT USED, using UIAlertController in LiftsViewController instead

class AddLiftViewController: UIViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationItem.hidesBackButton = true
    }
    
    @IBAction private func done(sender: AnyObject) {
        navigationController?.popViewControllerAnimated(true)
    }
    
    @IBAction private func add(sender: AnyObject) {
        FinalProjectDAO.sharedFinalProjectDAO.addLiftWithName(liftNameTextField.text, andSets: setsTextField.text.toInt()!, andRepsPerSet: repsPerSetTextField.text.toInt()!, inWorkout: selectedWorkout)
        liftNameTextField.text = ""
        setsTextField.text = ""
        repsPerSetTextField.text = ""
    }
    
    var selectedWorkout: Workout!
    @IBOutlet weak var repsPerSetTextField: UITextField!
    @IBOutlet weak var setsTextField: UITextField!
    @IBOutlet weak var liftNameTextField: UITextField!
    @IBOutlet weak var addButton: UIBarButtonItem!
    @IBOutlet weak var doneButton: UIBarButtonItem!
}