//
//  FinalProjectDAO.swift
//  FinalProject
//
//  Created by Jared Goddard on 8/3/15.
//
//

import Foundation
import CoreData
import CoreDataService

class FinalProjectDAO: DataAccessObject {
    // MARK: DAO
    func fetchedResultsControllerForDayList() -> NSFetchedResultsController? {
        var result: NSFetchedResultsController?
        
        CoreDataService.sharedCoreDataService.beginSynchronousReadOnlyDataOperationForDataAccessObject(self, operation: { (context) -> Void in
            let fetchRequest = NSFetchRequest(namedEntity: Day.self)
            fetchRequest.sortDescriptors = [NSSortDescriptor(key: "dayName", ascending: true)]
            fetchRequest.fetchBatchSize = 7
            
            let resultsController = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: context, sectionNameKeyPath: nil, cacheName: nil)
            
            var error: NSError?
            if !resultsController.performFetch(&error) {
                println("Failed to perform fetch for day list fetched results controller")
                if let someError = error {
                    println(someError)
                }
            }
            else {
                result = resultsController
            }
        })
        
        return result
    }
    
    func fetchedResultsControllerForWorkoutInDay(day: Day) -> NSFetchedResultsController? {
        var result: NSFetchedResultsController?
        
        CoreDataService.sharedCoreDataService.beginSynchronousReadOnlyDataOperationForDataAccessObject(self, operation: { (context) -> Void in
            let fetchRequest = NSFetchRequest(namedEntity: Workout.self)
            fetchRequest.predicate = NSPredicate(format: "day == %@", day)
            fetchRequest.sortDescriptors = [NSSortDescriptor(key: "workoutName", ascending: true)]
            fetchRequest.fetchBatchSize = 15
            
            let resultsController = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: context, sectionNameKeyPath: nil, cacheName: nil)
            
            var error: NSError?
            if !resultsController.performFetch(&error) {
                println("Failed to perform fetch for shelf list fetched results controller")
                if let someError = error {
                    println(someError)
                }
            }
            else {
                result = resultsController
            }
        })
        
        return result
    }
    
    func addWorkoutWithName(workoutName: String, inDay day: Day) {
        CoreDataService.sharedCoreDataService.beginAsynchronousDataOperationForDataAccessObject(self, operation: { (context: NSManagedObjectContext, operationFinalizationHandler: OperationFinalizationHandler) -> Void in
            context.performBlock({ () -> Void in
                let contextSpecificDay = CoreDataService.sharedCoreDataService.lookupManagedObject(day, appropriateForUseInContext: context)
                let workout = NSEntityDescription.insertNewObjectForNamedEntity(Workout.self, inManagedObjectContext: context)
                workout.workoutName = workoutName
                workout.day = contextSpecificDay
                
                operationFinalizationHandler(save: true, saveCompletionHandler: nil)
            })
        })
    }
    
    func renameWorkout(workout: Workout, withNewName newName: String) {
        CoreDataService.sharedCoreDataService.beginAsynchronousDataOperationForDataAccessObject(self, operation: { (context: NSManagedObjectContext, operationFinalizationHandler: OperationFinalizationHandler) -> Void in
            context.performBlock({ () -> Void in
                let contextSpecificWorkout = CoreDataService.sharedCoreDataService.lookupManagedObject(workout, appropriateForUseInContext: context)
                contextSpecificWorkout.workoutName = newName
                
                operationFinalizationHandler(save: true, saveCompletionHandler: nil)
            })
        })
    }
    
    func deleteWorkout(workout: Workout, withSaveCompletionHandler saveCompletionHandler: SaveCompletionHandler) {
        CoreDataService.sharedCoreDataService.beginMainQueueAsynchronousDataOperationForDataAccessObject(self, operation: { (context: NSManagedObjectContext, operationFinalizationHandler: OperationFinalizationHandler) -> Void in
            context.deleteObject(workout)
            
            operationFinalizationHandler(save: true, saveCompletionHandler: saveCompletionHandler)
        })
    }
    
    /*
    
    func addLiftWithName(name: String, andSets sets: Int, andReps reps: Int, inDay day: Day, inWorkout workout: Workout) {
        CoreDataService.sharedCoreDataService.beginAsynchronousDataOperationForDataAccessObject(self, operation: { (context: NSManagedObjectContext, operationFinalizationHandler: OperationFinalizationHandler) -> Void in
            context.performBlock({ () -> Void in
                let contextSpecificWorkout = CoreDataService.sharedCoreDataService.lookupManagedObject(workout, appropriateForUseInContext: context)
                let contextSpecificDay = CoreDataService.sharedCoreDataService.lookupManagedObject(day, appropriateForUseInContext: context)
                let lift = NSEntityDescription.insertNewObjectForNamedEntity(Lift.self, inManagedObjectContext: context)
                lift.liftName = name
                lift.sets = sets
                lift.reps = reps
                lift.workout = contextSpecificWorkout
                lift.workout.day = contextSpecificDay
                
                operationFinalizationHandler(save: true, saveCompletionHandler: nil)
            })
        })
    }
    
    func updateLift(lift: Lift, withNewName newName: String, andNewSets newSets: Int, andNewReps newReps: Int) {
        CoreDataService.sharedCoreDataService.beginAsynchronousDataOperationForDataAccessObject(self, operation: { (context: NSManagedObjectContext, operationFinalizationHandler: OperationFinalizationHandler) -> Void in
            context.performBlock({ () -> Void in
                let contextSpecificBook = CoreDataService.sharedCoreDataService.lookupManagedObject(lift, appropriateForUseInContext: context)
                contextSpecificLift.name = newName
                contextSpecificLift.sets = newSets
                contextSpecificLift.reps = newReps
                
                operationFinalizationHandler(save: true, saveCompletionHandler: nil)
            })
        })
    }
    
    func deleteLift(lift: Lift) {
        CoreDataService.sharedCoreDataService.beginMainQueueAsynchronousDataOperationForDataAccessObject(self, operation: { (context: NSManagedObjectContext, operationFinalizationHandler: OperationFinalizationHandler) -> Void in
            context.performBlock({ () -> Void in
                context.deleteObject(lift)
                
                operationFinalizationHandler(save: true, saveCompletionHandler: nil)
            })
        })
    }

    */
    
    // MARK: Initialization
    private init() {
    }
    
    // MARK: Singleton
    static var sharedFinalProjectDAO = FinalProjectDAO()
}