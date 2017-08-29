//
//  NSFetchedResultsController+Extension.swift
//  Timibo
//
//  Created by Knight on 05/08/2017.
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
