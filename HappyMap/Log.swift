//
//  Log.swift
//  HappyMap
//
//  Created by Игорь Моренко on 05.02.16.
//  Copyright © 2016 LionSoft LLC. All rights reserved.
//

import Foundation
import CoreData


class Log: NSManagedObject {

    @NSManaged var category: NSNumber?
    @NSManaged var date: NSDate?
    @NSManaged var fsync: NSNumber?
    @NSManaged var latitude: NSNumber?
    @NSManaged var longitude: NSNumber?
    @NSManaged var rate: NSNumber?
}
