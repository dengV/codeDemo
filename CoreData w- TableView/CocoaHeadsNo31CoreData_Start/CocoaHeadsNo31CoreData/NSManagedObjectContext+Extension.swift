//
//  NSManagedObjectContext+Extension.swift
//  CocoaHeadsNo31CoreData
//
//  Created by Knight on 29/08/2017.
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
