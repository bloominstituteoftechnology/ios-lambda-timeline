//
//  CoreDataStack.swift
//  ImageFilterEditor
//
//  Created by Chris Dobek on 6/4/20.
//  Copyright © 2020 Chris Dobek. All rights reserved.
//

import Foundation
import CoreData

class CoreDataStack {
    static let shared = CoreDataStack()
    
    private init() {}
    
    lazy var container: NSPersistentContainer = {
        let newContainer = NSPersistentContainer(name: "Image")
        newContainer.loadPersistentStores { (_, error) in
            if let error = error {
                fatalError("Failed to load persistent stores: \(error)")
            }
        }
        newContainer.viewContext.automaticallyMergesChangesFromParent = true
        return newContainer
    }()
    
    var mainContext: NSManagedObjectContext {
        return container.viewContext
    }
    
    func save(context: NSManagedObjectContext) throws {
        var saveError: Error?
        context.performAndWait {
            do {
                try context.save()
            } catch {
                saveError = error
            }
        }
        if let saveError = saveError { throw saveError }
    }
}

