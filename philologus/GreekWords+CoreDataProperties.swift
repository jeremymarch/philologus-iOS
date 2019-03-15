//
//  GreekWords+CoreDataProperties.swift
//  philolog.us
//
//  Created by Jeremy March on 6/1/17.
//  Copyright © 2017 Jeremy March. All rights reserved.
//

import Foundation
import CoreData


extension GreekWords {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<GreekWords> {
        return NSFetchRequest<GreekWords>(entityName: "GreekWords")
    }

    @NSManaged public var seq: Int32
    @NSManaged public var unaccentedWord: String?
    @NSManaged public var word: String?
    @NSManaged public var wordid: Int32

}
