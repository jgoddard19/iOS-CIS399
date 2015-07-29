//
//  CoreDataService.swift
//
//  Created by Charles Augustine.
//  Copyright (c) 2015 Charles Augustine. All rights reserved.
//


import CoreData
import Foundation


public let CoreDataServiceInitializationFinishedNotification = "CoreDataServiceInitializationFinishedNotification"

/// This is a test
public typealias SaveCompletionHandler = (success: Bool, error: NSError?) -> Void
public typealias OperationFinalizationHandler = (save: Bool, saveCompletionHandler: SaveCompletionHandler?) -> Void
public typealias SynchronousReadOnlyDataOperation = (context: NSManagedObjectContext) -> Void
public typealias AsynchronousDataOperation = (context: NSManagedObjectContext, operationFinalizationHandler: OperationFinalizationHandler) -> Void


public class CoreDataService {
	// MARK: Public
	public func lookupManagedObject<T: NSManagedObject>(managedObject: T, appropriateForUseInContext context: NSManagedObjectContext) -> T {
		return context.objectWithID(managedObject.permanentObjectID!) as! T
	}

	// MARK: DAO
	public func beginSynchronousReadOnlyDataOperationForDataAccessObject(dataAccessObject: DataAccessObject, @noescape operation: SynchronousReadOnlyDataOperation) {
		if initializationFinished {
			operation(context: mainQueueContext)
		}
		else {
			println("Attempted to begin synchronous read only data operation before initialization finished, ignoring")
		}
	}

	public func beginAsynchronousDataOperationForDataAccessObject(dataAccessObject: DataAccessObject, operation: AsynchronousDataOperation) {
		beginAsynchronousDataOperationForDataAccessObject(dataAccessObject, onMainQueue: false, operation: operation)
	}
	
	public func beginMainQueueAsynchronousDataOperationForDataAccessObject(dataAccessObject: DataAccessObject, operation: AsynchronousDataOperation) {
		beginAsynchronousDataOperationForDataAccessObject(dataAccessObject, onMainQueue: true, operation: operation)
	}
	
	// MARK: Private
	private func beginAsynchronousDataOperationForDataAccessObject(dataAccessObject: DataAccessObject, onMainQueue: Bool, operation: AsynchronousDataOperation) {
		if initializationFinished {
			let operationUUID = NSUUID()

			let context = managedObjectContextForAsynchronousDataOperation(operationUUID, onMainQueue:onMainQueue)

			operation(context: context) { (save, saveCompletionHandler) in
				self.cleanupManagedObjectContextForAsynchronousDataOperation(operationUUID, andSaveContext: save, completionHandler: saveCompletionHandler)
			}
		}
		else {
			if onMainQueue {
				println("Attempted to begin asynchronous data operation on main queue before initialization finished, ignoring")
			}
			else {
				println("Attempted to begin asynchronous data operation before initialization finished, ignoring")
			}
		}
	}

	private func managedObjectContextForAsynchronousDataOperation(operationUUID: NSUUID, onMainQueue: Bool) -> NSManagedObjectContext {
		var context: NSManagedObjectContext? = nil
		dispatch_sync(writingOperationContextsAccessQueue) {
			context = self.writingOperationContexts[operationUUID]

			if context == nil {
				let newContext: NSManagedObjectContext
				if onMainQueue {
					newContext = self.mainQueueContext
				}
				else {
					newContext = NSManagedObjectContext(concurrencyType: .PrivateQueueConcurrencyType)
					newContext.parentContext = self.mainQueueContext
				}
				newContext.undoManager = nil

				self.writingOperationContexts[operationUUID] = newContext

				context = newContext
			}
		}

		return context!
	}

	private func cleanupManagedObjectContextForAsynchronousDataOperation(operationUUID: NSUUID, andSaveContext save: Bool, completionHandler: SaveCompletionHandler?) {
		var writingOperationContext: NSManagedObjectContext?
		dispatch_sync(writingOperationContextsAccessQueue) {
			if let someWritingOperationContext = self.writingOperationContexts[operationUUID] {
				writingOperationContext = someWritingOperationContext
				self.writingOperationContexts.removeValueForKey(operationUUID)
			}
			else {
				println("Error: Could not find context to cleanup for writing operation with identifier \(operationUUID)")
			}
		}

		if let someWritingOperationContext = writingOperationContext where save {
			someWritingOperationContext.performBlock() {
				var error: NSError?
				if someWritingOperationContext.save(&error) {
					if someWritingOperationContext != self.mainQueueContext {
						self.mainQueueContext.performBlock() {
							var error: NSError?
							if self.mainQueueContext.save(&error) {
								self.saveRootContext() { (success, error) in
									if(!success) {
										println("Error: Failed to root parent context while cleaning up context for writing operation with identifier \(operationUUID)")
									}

									completionHandler?(success: success, error: error)
								}
							}
							else {
								println("Error: Failed to save main queue context while cleaning up context for writing operation with identifier \(operationUUID)")

								self.mainQueueContext.rollback()

								completionHandler?(success: false, error: error)
							}
						}
					}
					else {
						self.saveRootContext() { (success, error) in
							if(!success) {
								println("Error: Failed to root parent context while cleaning up context for writing operation with identifier \(operationUUID)")
							}

							completionHandler?(success: success, error: error)
						}
					}
				}
				else {
					println("Error: Failed to save writing operation context while cleaning up context for writing operation with identifier \(operationUUID)")

					completionHandler?(success: false, error: error)
				}
			}
		}
		else {
			dispatch_async(dispatch_get_main_queue()) {
				completionHandler?(success: !save, error: nil)
			}
		}
	}

	private func saveRootContext(completionHandler: SaveCompletionHandler) {
		self.rootContext.performBlock() {
			var error: NSError?
			var success = self.rootContext.save(&error)
			if !success {
				self.rootContext.rollback()
				self.mainQueueContext.reset()
			}

			dispatch_async(dispatch_get_main_queue()) {
				completionHandler(success: success, error: error)
			}
		}
	}

	// MARK: Initialization
	private init() {
		let bundle = NSBundle.mainBundle()
		if let modelPath = bundle.URLForResource(CoreDataService.modelName, withExtension: "momd") {
			if let someManagedObjectModel = NSManagedObjectModel(contentsOfURL: modelPath) {
				managedObjectModel = someManagedObjectModel
				persistentStoreCoordinator = NSPersistentStoreCoordinator(managedObjectModel: managedObjectModel)

				if let documentsDirectoryPath = NSSearchPathForDirectoriesInDomains(.DocumentDirectory, .UserDomainMask, true).first as? String {
					let storeRootPath = documentsDirectoryPath.stringByAppendingPathComponent("DataStore")

					let fileManager = NSFileManager.defaultManager()
					if !fileManager.fileExistsAtPath(storeRootPath) {
						fileManager.createDirectoryAtPath(storeRootPath, withIntermediateDirectories: true, attributes: nil, error: nil)
					}

					let persistentStorePath = storeRootPath.stringByAppendingPathComponent("\(CoreDataService.storeName).sqlite")
					let shouldSetupStore = !fileManager.fileExistsAtPath(persistentStorePath)
					let persistentStoreOptions = [NSMigratePersistentStoresAutomaticallyOption: true, NSInferMappingModelAutomaticallyOption: true]

					var persistentStoreError: NSError? = nil
					if persistentStoreCoordinator.addPersistentStoreWithType(NSSQLiteStoreType, configuration: nil, URL: NSURL.fileURLWithPath(persistentStorePath), options: persistentStoreOptions, error: &persistentStoreError) == nil {
						println("Error adding persistent store to the persistent store coordinator: \(persistentStoreError)")

						abort()
					}

					rootContext = NSManagedObjectContext(concurrencyType: NSManagedObjectContextConcurrencyType.PrivateQueueConcurrencyType)
					rootContext.persistentStoreCoordinator = persistentStoreCoordinator
					rootContext.undoManager = nil

					mainQueueContext = NSManagedObjectContext(concurrencyType: NSManagedObjectContextConcurrencyType.MainQueueConcurrencyType)
					mainQueueContext.parentContext = rootContext
					mainQueueContext.undoManager = nil

					if let someDataInitializer = CoreDataService.dataInitializer where shouldSetupStore {
						CoreDataService.dataInitializer?.initializeDataForNewStoreInContext(rootContext)

						saveRootContext() { (success, error) in
							if !success {
								println("Failed to save after calling DataInitializer's initializeDataForNewStoreInContext: \(error)")

								fileManager.removeItemAtPath(storeRootPath, error: nil)
								abort()
							}
							else {
								self.initializationFinished = true

								NSNotificationCenter.defaultCenter().postNotificationName(CoreDataServiceInitializationFinishedNotification, object: self)
							}
						}
					}
					else {
						initializationFinished = true

						NSNotificationCenter.defaultCenter().postNotificationName(CoreDataServiceInitializationFinishedNotification, object: self)
					}
				}
				else {
					println("Could not find documents directory")

					abort()
				}
			}
			else {
				println("Could not load model at URL \(modelPath)")

				abort()
			}
		}
		else {
			println("Could not find model file with name \"\(CoreDataService.modelName)\", please set CoreDataService.modelName to the name of the model file (without the file extension)")

			abort()
		}
	}

	// MARK: Properties
	public private(set) var initializationFinished = false

	// MARK: Properties (Private)
	private let managedObjectModel: NSManagedObjectModel
	private let persistentStoreCoordinator: NSPersistentStoreCoordinator
	private let rootContext: NSManagedObjectContext
	private let mainQueueContext: NSManagedObjectContext

	private let writingOperationContextsAccessQueue = dispatch_queue_create("ContextsAccess", nil)
	private var writingOperationContexts: Dictionary<NSUUID, NSManagedObjectContext> = [:]

	// MARK: Properties (Static)
	public static var modelName = "Model"
	public static var storeName = "Model"
	public static var dataInitializer: DataInitializer?
	public static let sharedCoreDataService = CoreDataService()
}