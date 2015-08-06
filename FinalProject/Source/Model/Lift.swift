//
//  Lift.swift
//  FinalProject
//
//  Created by Jared Goddard on 8/3/15.
//
//

import CoreData
import CoreDataService
import Foundation


class Lift: NSManagedObject, NamedEntity {
    // MARK: Properties (NamedEntity)
    static var entityName: String {
        return "Lift"
    }
    
    // MARK: Properties (Core Data Attributes)
    @NSManaged var liftName: String
    @NSManaged var sets: NSNumber
    @NSManaged var repsPerSet: NSNumber
    
    // MARK: Properties (Core Data Relationships)
    @NSManaged var workout: Workout
    
}
