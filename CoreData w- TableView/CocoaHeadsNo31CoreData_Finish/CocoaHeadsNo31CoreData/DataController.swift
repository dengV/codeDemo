//
//  DataController.swift
//  CocoaHeadsNo31CoreData
//
//  Created by Knight on 29/08/2017.
//  Copyright © 2017 Knight. All rights reserved.
//

import UIKit
import CoreData

class DataController: NSObject {

    var persistentContainer: NSPersistentContainer
    
    init(completionClosure: @escaping () -> ()) {
        persistentContainer = NSPersistentContainer(name: "DataModel")
        persistentContainer.loadPersistentStores() { (description, error) in
            if let error = error {
                fatalError("Failed to load Core Data stack: \(error)")
            }

            description.shouldMigrateStoreAutomatically = true
            description.shouldInferMappingModelAutomatically = true

            completionClosure()
        }
    }
}
