//
//  NSManagedObjectContext+Extension.swift
//  Timibo
//
//  Created by Knight on 05/08/2017.
//  Copyright © 2017 Knight. All rights reserved.
//

import Foundation
import CoreData

extension NSManagedObjectContext {

    func saveContext(){
        do {
            try self.save()
        } catch {
            fatalError("Failure to save context: \(error)")
        }
    }
}
