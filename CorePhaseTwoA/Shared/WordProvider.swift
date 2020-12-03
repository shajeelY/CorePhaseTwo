//
//  WordProvider.swift
//  CorePhaseTwoA
//
//  Created by Shajeel Yahya on 12/1/20.
//

import CoreData
// MARK: - Core Data stack
class WordProvider {
let kArray: KanjiArray = KanjiArray()
    
lazy var persistentContainer: NSPersistentContainer = {
let container = NSPersistentContainer(name: "CorePhaseTwoA")
container.loadPersistentStores(completionHandler: { (storeDescription, error) in
        if let error = error as NSError? {
            fatalError("Unresolved error \(error), \(error.userInfo)")
        }
        container.viewContext.mergePolicy = NSMergeByPropertyObjectTrumpMergePolicy
    })
    return container
}()

// MARK: - Core Data Saving support
private func newTaskContext() -> NSManagedObjectContext {
    // Create a private queue context.
    let taskContext = persistentContainer.newBackgroundContext()
    taskContext.mergePolicy = NSMergeByPropertyObjectTrumpMergePolicy
    // Set unused undoManager to nil for macOS (it is nil by default on iOS)
    // to reduce resource requirements.
    taskContext.undoManager = nil
    return taskContext
}

func fetchKanji(completionHandler: @escaping (Error?) -> Void) {

        do {
            kArray.startParsing()
            print("\(Date()) Parsing Began")
            // Import the GeoJSON into Core Data.
            if #available(iOS 13, macOS 10.15, *) {
                try self.importQuakesUsingBIR(from: kArray.kanjiDictionary)
            } else {
                try self.importQuakesBeforeBIR(from: kArray.kanjiDictionary)
            }
         
            
        } catch {
            // Alert the user if data cannot be digested.
            completionHandler(error)
            return
        }
        completionHandler(nil)
    }

    private func importQuakesUsingBIR(from geoKanji: [[String: Any]]) throws {
    var performError: Error?
        
        let taskContext = newTaskContext()
        taskContext.performAndWait {
        let batchInsert = self.newBatchInsertRequest(with: geoKanji)

            batchInsert.resultType = .statusOnly
            
            if let batchInsertResult = try? taskContext.execute(batchInsert) as? NSBatchInsertResult,
                let success = batchInsertResult.result as? Bool, success {
                print("\(Date()) Imported to CorData")
                return
            }
            performError = QuakeError.batchInsertError
        }

        if let error = performError {
            throw error
        }
    }


    private func newBatchInsertRequest(with kDictionaryList: [[String: Any]]) -> NSBatchInsertRequest {
        let batchInsert: NSBatchInsertRequest
        if #available(iOS 14, macOS 10.16, *) {
            // Provide one dictionary at a time when the block is called.
            var index = 0
            let total = kDictionaryList.count
            batchInsert = NSBatchInsertRequest(entityName: "Word", dictionaryHandler: { dictionary in
                guard index < total else { return true }
                dictionary.addEntries(from: kDictionaryList[index])
                index += 1
                print("\(Date()) \(190030-index) Kanji remaining")
                return false
            })
        } else {
            // Provide the dictionaries all together.
            batchInsert = NSBatchInsertRequest(entityName: "Word", objects: kDictionaryList)
        }
        return batchInsert
    }
    
    /**
     Imports a JSON dictionary into the Core Data store on a private queue,
     processing the record in batches to avoid a high memory footprint.
    */
    private func importQuakesBeforeBIR(from kanjiArray: [[String: Any]]) throws {
        guard !kArray.kanjiDictionary.isEmpty else { return }
                
        // Process records in batches to avoid a high memory footprint.
        let batchSize = 256
        let count = kArray.kanjiDictionary.count
        
        // Determine the total number of batches.
        var numBatches = count / batchSize
        numBatches += count % batchSize > 0 ? 1 : 0
        
        for batchNumber in 0 ..< numBatches {
            // Determine the range for this batch.
            let batchStart = batchNumber * batchSize
            let batchEnd = batchStart + min(batchSize, count - batchNumber * batchSize)
            let range = batchStart..<batchEnd
            
            // Create a batch for this range from the decoded JSON.
            // Stop importing if any batch is unsuccessful.
            try importOneBatch(Array(kanjiArray[range]))
        }
    }
    
    /**
     Imports one batch of words, creating managed objects from the new data,
     and saving them to the persistent store, on a private queue. After saving,
     resets the context to clean up the cache and lower the memory footprint.
     
     NSManagedObjectContext.performAndWait doesn't rethrow so this function
     catches throws within the closure and uses a return value to indicate
     whether the import is successful.
    */
    private func importOneBatch(_ wordDictionaryBatch: [[String: Any]]) throws {
        let taskContext = newTaskContext()
        var performError: Error?
        
        // taskContext.performAndWait runs on the URLSession's delegate queue
        // so it won’t block the main thread.
        taskContext.performAndWait {
            // Create a new record for each quake in the batch.
            for kanjiword in wordDictionaryBatch {
                // Create a Quake managed object on the private queue context.
                guard let kanjiWord = NSEntityDescription.insertNewObject(forEntityName: "Word", into: taskContext) as? Word else {
                    performError = QuakeError.creationError
                    return
                }
                
                // Populate the Quake's properties using the raw data.
                do {
                    try kanjiWord.update(with: kanjiword)
                } catch {
                    // QuakeError.missingData: Delete invalid Quake from the private queue context and continue.
                    print(QuakeError.missingData.localizedDescription)
                    taskContext.delete(kanjiWord)
                }
            }
            
            // Save all insertions and deletions from the context to the store.
            if taskContext.hasChanges {
                do {
                    try taskContext.save()
                } catch {
                    performError = error
                    return
                }
                // Reset the taskContext to free the cache and lower the memory footprint.
                taskContext.reset()
            }
        }
        
        if let error = performError {
            throw error
        }
    }

    func deleteAll(completionHandler: @escaping (Error?) -> Void) {
        let taskContext = newTaskContext()
        taskContext.perform {
            let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Word")
            let batchDeleteRequest = NSBatchDeleteRequest(fetchRequest: fetchRequest)
            batchDeleteRequest.resultType = .resultTypeCount
            
            // Execute the batch insert
            if let batchDeleteResult = try? taskContext.execute(batchDeleteRequest) as? NSBatchDeleteResult,
                batchDeleteResult.result != nil {
                completionHandler(nil)

            } else {
                completionHandler(QuakeError.batchDeleteError)
            }
        }
    }

    // MARK: - NSFetchedResultsController
    
    /**
     A fetched results controller delegate to give consumers a chance to update
     the user interface when content changes.
     */
    weak var fetchedResultsControllerDelegate: NSFetchedResultsControllerDelegate?
    
    /**
     A fetched results controller to fetch Quake records sorted by time.
     */
    lazy var fetchedResultsController: NSFetchedResultsController<Word> = {
        
        // Create a fetch request for the Quake entity sorted by time.
        let fetchRequest = NSFetchRequest<Word>(entityName: "Word")
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "ent_seq", ascending: false)]
        fetchRequest.propertiesToFetch = ["k_ele", "r_ele", "sense", "ent_seq"]
        // Create a fetched results controller and set its fetch request, context, and delegate.
        let controller = NSFetchedResultsController(fetchRequest: fetchRequest,
                                                    managedObjectContext: persistentContainer.viewContext,
                                                    sectionNameKeyPath: nil, cacheName: nil)
        controller.delegate = fetchedResultsControllerDelegate
        
        // Perform the fetch.
        do {
            try controller.performFetch()
            print("Performing ResultsControllerFetch")
        } catch {
            fatalError("Unresolved error \(error)")
        }
        
        return controller
    }()
    
    /**
     Resets viewContext and refetches the data from the store.
     */
    func resetAndRefetch() {
        persistentContainer.viewContext.reset()
        do {
            try fetchedResultsController.performFetch()
        } catch {
            fatalError("Unresolved error \(error)")
        }
    }
    
    // MARK: - NSPersistentStoreRemoteChange handler

    /**
     Handles remote store change notifications (.NSPersistentStoreRemoteChange).
     storeRemoteChange runs on the queue where the changes were made.
     */
    @objc
    func storeRemoteChange(_ notification: Notification) {
        // print("\(#function): Got a persistent store remote change notification!")
    }

/*
func saveContext () {
    let context = persistentContainer.viewContext
    if context.hasChanges {
        do {
            try context.save()
        } catch {
            let nserror = error as NSError
            fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
        }
    }
}
*/
}
