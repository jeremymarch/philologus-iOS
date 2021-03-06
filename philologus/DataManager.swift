//
//  DataManager.swift
//  philologus
//
//  Created by Jeremy March on 4/5/18.
//  Copyright © 2018 Jeremy March. All rights reserved.
//

// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/.
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
