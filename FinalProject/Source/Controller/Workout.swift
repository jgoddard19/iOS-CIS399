//
//  Workout.swift
//  FinalProject
//
//  Created by Jared Goddard on 7/30/15.
//
//

import CoreData
import CoreDataService
import Foundation


class Workout: NSManagedObject, NamedEntity {
    // MARK: Properties (NamedEntity)
    static var entityName: String {
        return "Workout"
    }
    
    // MARK: Properties (Core Data Attributes)
    @NSManaged var workoutName: String
    @NSManaged var time: time_value
    
    // MARK: Properties (Core Data Relationships)
    @NSManaged var day: Day
    @NSManaged var lift: Lift
}