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
        day.orderIndex = 1
        
        var workout = NSEntityDescription.insertNewObjectForNamedEntity(Workout.self, inManagedObjectContext: context)
        workout.workoutName = "(Placeholder) Chest workout"
        workout.day = day
        
        var lift = NSEntityDescription.insertNewObjectForNamedEntity(Lift.self, inManagedObjectContext: context)
        lift.liftName = "(Placeholder) Bench press"
        lift.sets = 5
        lift.repsPerSet = 5
        lift.workout = workout

        lift = NSEntityDescription.insertNewObjectForNamedEntity(Lift.self, inManagedObjectContext: context)
        lift.liftName = "(Placeholder) Dumbbell incline press"
        lift.sets = 5
        lift.repsPerSet = 5
        lift.workout = workout

        lift = NSEntityDescription.insertNewObjectForNamedEntity(Lift.self, inManagedObjectContext: context)
        lift.liftName = "(Placeholder) Dumbbell flys"
        lift.sets = 3
        lift.repsPerSet = 10
        lift.workout = workout
        
        day = NSEntityDescription.insertNewObjectForNamedEntity(Day.self, inManagedObjectContext: context)
        day.dayName = "Tuesday"
        day.orderIndex = 2
        
        workout = NSEntityDescription.insertNewObjectForNamedEntity(Workout.self, inManagedObjectContext: context)
        workout.workoutName = "(Placeholder) Leg workout"
        workout.day = day
        
        day = NSEntityDescription.insertNewObjectForNamedEntity(Day.self, inManagedObjectContext: context)
        day.dayName = "Wednesday"
        day.orderIndex = 3
        
        day = NSEntityDescription.insertNewObjectForNamedEntity(Day.self, inManagedObjectContext: context)
        day.dayName = "Thursday"
        day.orderIndex = 4
        
        day = NSEntityDescription.insertNewObjectForNamedEntity(Day.self, inManagedObjectContext: context)
        day.dayName = "Friday"
        day.orderIndex = 5
        
        day = NSEntityDescription.insertNewObjectForNamedEntity(Day.self, inManagedObjectContext: context)
        day.dayName = "Saturday"
        day.orderIndex = 6
        
        day = NSEntityDescription.insertNewObjectForNamedEntity(Day.self, inManagedObjectContext: context)
        day.dayName = "Sunday"
        day.orderIndex = 7
    }
}