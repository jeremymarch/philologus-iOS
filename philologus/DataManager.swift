//
//  DataManager.swift
//  philologus
//
//  Created by Jeremy March on 4/5/18.
//  Copyright © 2018 Jeremy March. All rights reserved.
//

import Foundation
import CoreData

class DataManager {
    
    // MARK: - Properties
    
    static let shared = DataManager()
    
    // MARK: -
    
    var backgroundContext: NSManagedObjectContext?
    var mainContext: NSManagedObjectContext?
    
    // Initialization
    
    private init() {
        backgroundContext = nil
    }
    
}
