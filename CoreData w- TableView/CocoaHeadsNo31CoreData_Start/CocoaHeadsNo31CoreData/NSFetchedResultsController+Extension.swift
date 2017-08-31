//
//  NSFetchedResultsController+Extension.swift
//  CocoaHeadsNo31CoreData
//
//  Created by Knight on 29/08/2017.
//  Copyright © 2017 Knight. All rights reserved.
//


import Foundation
import CoreData

extension NSFetchedResultsController {

    func performFetchForResults(){
        do {
            try self.performFetch()

        } catch {

            fatalError("Failed to initialize FetchedResultsController with error: \(error)")
        }
    }
}
