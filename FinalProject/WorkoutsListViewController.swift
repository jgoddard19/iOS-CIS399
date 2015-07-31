//
//  WorkoutsListViewController.swift
//  FinalProject
//
//  Created by Jared Goddard on 7/30/15.
//
//

import Foundation
import UIKit

class WorkoutsListViewController: UITableViewController {
    @IBOutlet weak var workoutsListViewTitle: UINavigationItem!
    
    var day: String?
    
    // MARK: Properties
    var workouts = Array<String>() {
        didSet {
            if(self.isViewLoaded()) {
                workoutsListView.reloadData()
            }
        }
    }
    
    func tableView(workoutsView: UITableView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("WorkoutCell", forIndexPath: indexPath) as! UITableViewCell
        //cell.textLabel?.text = UITableViewCell(named: workouts[indexPath.item])
        
        return cell
    }
    
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return workouts.count
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    override func viewDidDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //println("\(day!)")
        //workoutsListViewTitle.title = day!
    }
    
    @IBOutlet weak var workoutsListView: UITableView!
}