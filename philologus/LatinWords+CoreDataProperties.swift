//
//  LatinWords+CoreDataProperties.swift
//  philolog.us
//
//  Created by Jeremy March on 6/1/17.
//  Copyright © 2017 Jeremy March. All rights reserved.
//

import Foundation
import CoreData


extension LatinWords {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<LatinWords> {
        return NSFetchRequest<LatinWords>(entityName: "LatinWords")
    }

    @NSManaged public var seq: Int32
    @NSManaged public var unaccentedWord: String?
    @NSManaged public var word: String?
    @NSManaged public var wordid: Int32

}
