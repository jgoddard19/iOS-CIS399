//
//  Day.swift
//  FinalProject
//
//  Created by Jared Goddard on 7/30/15.
//
//

import CoreData
import CoreDataService
import Foundation


class Day: NSManagedObject, NamedEntity {
    // MARK: Properties (NamedEntity)
    static var entityName: String {
        return "Day"
    }
    
    // MARK: Properties (Core Data Attributes)
    @NSManaged var dayName: String
    @NSManaged var orderIndex: NSNumber
    
    // MARK: Properties (Core Data Relationships)
    @NSManaged var workouts: NSSet
    
}