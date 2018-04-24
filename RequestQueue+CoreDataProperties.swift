//
//  RequestQueue+CoreDataProperties.swift
//  philologus
//
//  Created by Jeremy March on 4/8/18.
//  Copyright © 2018 Jeremy March. All rights reserved.
//
//

import Foundation
import CoreData


extension RequestQueue {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<RequestQueue> {
        return NSFetchRequest<RequestQueue>(entityName: "RequestQueue")
    }

    @NSManaged public var data: String?
    @NSManaged public var url: String?

}
