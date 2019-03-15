//
//  LatinDefs+CoreDataProperties.swift
//  philologus
//
//  Created by Jeremy March on 4/7/18.
//  Copyright © 2018 Jeremy March. All rights reserved.
//
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
