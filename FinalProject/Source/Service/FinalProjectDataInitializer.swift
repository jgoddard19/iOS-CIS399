//
//  DayDataInitializer.swift
//  FinalProject
//
//  Created by Jared Goddard on 8/3/15.
//
//

import CoreData
import CoreDataService
import Foundation


class FinalProjectDataInitializer: DataInitializer {
    func initializeDataForNewStoreInContext(context: NSManagedObjectContext) {
        var day = NSEntityDescription.insertNewObjectForNamedEntity(Day.self, inManagedObjectContext: context)
        day.dayName = "Monday"
        
        day = NSEntityDescription.insertNewObjectForNamedEntity(Day.self, inManagedObjectContext: context)
        day.dayName = "Tuesday"
        
        day = NSEntityDescription.insertNewObjectForNamedEntity(Day.self, inManagedObjectContext: context)
        day.dayName = "Wednesday"
        
        day = NSEntityDescription.insertNewObjectForNamedEntity(Day.self, inManagedObjectContext: context)
        day.dayName = "Thursday"
        
        day = NSEntityDescription.insertNewObjectForNamedEntity(Day.self, inManagedObjectContext: context)
        day.dayName = "Friday"
        
        day = NSEntityDescription.insertNewObjectForNamedEntity(Day.self, inManagedObjectContext: context)
        day.dayName = "Saturday"
        
        day = NSEntityDescription.insertNewObjectForNamedEntity(Day.self, inManagedObjectContext: context)
        day.dayName = "Sunday"
        
//        var workout = NSEntityDescription.insertNewObjectForNamedEntity(Workout.self, inManagedObjectContext: context)
//        workout.name = "Placeholder workout"
//        workout.day = day
//        
//        var lift = NSEntityDescription.insertNewObjectForNamedEntity(Lift.self, inManagedObjectContext: context)
//        lift.name = "Placeholder lift"
//        lift.sets = 0
//        lift.reps = 0
//        lift.workout = workout
    }
}