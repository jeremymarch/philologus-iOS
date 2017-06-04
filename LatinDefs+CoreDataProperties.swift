//
//  LatinDefs+CoreDataProperties.swift
//  philolog.us
//
//  Created by Jeremy March on 6/1/17.
//  Copyright © 2017 Jeremy March. All rights reserved.
//

import Foundation
import CoreData


extension LatinDefs {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<LatinDefs> {
        return NSFetchRequest<LatinDefs>(entityName: "LatinDefs")
    }

    @NSManaged public var def: String?
    @NSManaged public var wordid: Int32

}
