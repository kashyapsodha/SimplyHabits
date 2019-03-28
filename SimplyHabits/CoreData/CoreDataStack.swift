//
//  CoreDataStack.swift
//  SimplyHabits
//
//  Created by Kashyap Sodha on 3/12/19.
//  Copyright © 2019 Big Nerd Ranch. All rights reserved.
//

import Foundation
import CoreData

class CoreDataStack {
    var container: NSPersistentContainer {
        let container = NSPersistentContainer(name: "Habits")
        // Load our data model and set up a store to save our Habits to disk
        container.loadPersistentStores{ (description, error) in
            guard error == nil else {
                print("Error: \(error!)")
                return
            }
        }
        return container
    }
    // Its primary responsibility is to manage(save, delete) a collection of managed objects (habits)
    var managedContext: NSManagedObjectContext {
        return container.viewContext
    }
}
