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
    let days = DayService.sharedDayService.dayCategories();
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        titleLabel = days[indexPath.row].0
        println("\(titleLabel!)")
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
//        if (segue.identifier == "CollectionViewSegue") {
//            let destinationVC = segue.destinationViewController as! CatImagesViewController
//            destinationVC.category = titleLabel
//        }
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCellWithIdentifier("DayCell", forIndexPath: indexPath)
            as! UITableViewCell
        
        let name = days[indexPath.row]
        cell.textLabel?.text = name.0
        cell.detailTextLabel?.text = name.1
        
        return cell
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return days.count
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    override func viewDidDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
    }
}