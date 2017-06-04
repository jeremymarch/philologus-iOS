//
//  GreekDefs+CoreDataProperties.swift
//  philolog.us
//
//  Created by Jeremy March on 6/1/17.
//  Copyright © 2017 Jeremy March. All rights reserved.
//

import Foundation
import CoreData


extension GreekDefs {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<GreekDefs> {
        return NSFetchRequest<GreekDefs>(entityName: "GreekDefs")
    }

    @NSManaged public var def: String?
    @NSManaged public var wordid: Int32

}
