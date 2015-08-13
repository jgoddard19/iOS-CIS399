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
            fetchRequest.sortDescriptors = [NSSortDescriptor(key: "orderIndex", ascending: true)]
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
                println("Failed to perform fetch for workout list fetched results controller")
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
    
    func fetchedResultsControllerForLiftInWorkout(workout: Workout) -> NSFetchedResultsController? {
        var result: NSFetchedResultsController?
        
        CoreDataService.sharedCoreDataService.beginSynchronousReadOnlyDataOperationForDataAccessObject(self, operation: { (context) -> Void in
            let fetchRequest = NSFetchRequest(namedEntity: Lift.self)
            fetchRequest.predicate = NSPredicate(format: "workout == %@", workout)
            fetchRequest.sortDescriptors = [NSSortDescriptor(key: "liftName", ascending: true)]
            fetchRequest.fetchBatchSize = 15
            
            let resultsController = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: context, sectionNameKeyPath: nil, cacheName: nil)
            
            var error: NSError?
            if !resultsController.performFetch(&error) {
                println("Failed to perform fetch for lift list fetched results controller")
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
                println("Adding workout. Name: \(workout.workoutName) day: \(workout.day)")
                
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
    
    func setWorkoutTime(workout: Workout, withNewTime newTime: time_value) {
        CoreDataService.sharedCoreDataService.beginAsynchronousDataOperationForDataAccessObject(self, operation: { (context: NSManagedObjectContext, operationFinalizationHandler: OperationFinalizationHandler) -> Void in
            context.performBlock({ () -> Void in
                let contextSpecificWorkout = CoreDataService.sharedCoreDataService.lookupManagedObject(workout, appropriateForUseInContext: context)
                contextSpecificWorkout.time = newTime
                
                operationFinalizationHandler(save: true, saveCompletionHandler: nil)
            })
        })
    }
    
    func addLiftWithName(name: String, andSets sets: Int, andRepsPerSet repsPerSet: Int, inWorkout workout: Workout) {
        CoreDataService.sharedCoreDataService.beginAsynchronousDataOperationForDataAccessObject(self, operation: { (context: NSManagedObjectContext, operationFinalizationHandler: OperationFinalizationHandler) -> Void in
            context.performBlock({ () -> Void in
                let contextSpecificWorkout = CoreDataService.sharedCoreDataService.lookupManagedObject(workout, appropriateForUseInContext: context)
                let lift = NSEntityDescription.insertNewObjectForNamedEntity(Lift.self, inManagedObjectContext: context)
                lift.liftName = name
                lift.sets = sets
                lift.repsPerSet = repsPerSet
                lift.workout = contextSpecificWorkout
                
                operationFinalizationHandler(save: true, saveCompletionHandler: nil)
            })
        })
    }
    
    func updateLift(lift: Lift, withNewName newName: String, andNewSets newSets: Int, andNewRepsPerSet newRepsPerSet: Int) {
        CoreDataService.sharedCoreDataService.beginAsynchronousDataOperationForDataAccessObject(self, operation: { (context: NSManagedObjectContext, operationFinalizationHandler: OperationFinalizationHandler) -> Void in
            context.performBlock({ () -> Void in
                let contextSpecificLift = CoreDataService.sharedCoreDataService.lookupManagedObject(lift, appropriateForUseInContext: context)
                contextSpecificLift.liftName = newName
                contextSpecificLift.sets = newSets
                contextSpecificLift.repsPerSet = newRepsPerSet
                
                operationFinalizationHandler(save: true, saveCompletionHandler: nil)
            })
        })
    }
    
    func deleteLift(lift: Lift, withSaveCompletionHandler saveCompletionHandler: SaveCompletionHandler) {
        CoreDataService.sharedCoreDataService.beginMainQueueAsynchronousDataOperationForDataAccessObject(self, operation: { (context: NSManagedObjectContext, operationFinalizationHandler: OperationFinalizationHandler) -> Void in
            context.deleteObject(lift)
            
            operationFinalizationHandler(save: true, saveCompletionHandler: saveCompletionHandler)
        })
    }
    
    // MARK: Initialization
    private init() {
    }
    
    // MARK: Singleton
    static var sharedFinalProjectDAO = FinalProjectDAO()
}