//
//  DayListViewController.swift
//  FinalProject
//
//  Created by Jared Goddard on 7/29/15.
//
//

import Foundation
import UIKit

class DayListViewController: UITableViewController, UITableViewDataSource, UITableViewDelegate {
    
    var titleLabel: String?
    private var sharedDayList = DayService.sharedDayService.dayList();
    
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return sharedDayList.count
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        titleLabel = sharedDayList[indexPath.row].0
//        println("\(titleLabel!)")
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        switch segue.identifier {
        case .Some("DaySelectedSegue"):
            if let selectedRow = daysTable.indexPathForSelectedRow()?.row, let workouts = DayService.sharedDayService.daysForList(sharedDayList[selectedRow].title) {
                let workoutsListViewController = segue.destinationViewController as! WorkoutsListViewController
                workoutsListViewController.workouts = workouts
            }
        default:
            super.prepareForSegue(segue, sender: sender)
        }
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("DayCell", forIndexPath: indexPath) as! UITableViewCell
        cell.textLabel!.text = sharedDayList[indexPath.row].title
        cell.detailTextLabel!.text = sharedDayList[indexPath.row].subtitle
        
        return cell
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    override func viewDidDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    // MARK: Properties (IBOutlet)
    @IBOutlet private weak var daysTable: UITableView!
    
}