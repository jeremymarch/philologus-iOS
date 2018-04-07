//
//  GreekDefs+CoreDataProperties.swift
//  philologus
//
//  Created by Jeremy March on 4/7/18.
//  Copyright © 2018 Jeremy March. All rights reserved.
//
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
