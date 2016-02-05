//
//  Stat.swift
//  HappyMap
//
//  Created by Игорь Моренко on 05.02.16.
//  Copyright © 2016 LionSoft LLC. All rights reserved.
//

import Foundation
import CoreData
import MapKit


class Stat: NSManagedObject, MKAnnotation {

    @NSManaged var category: NSNumber?
    @NSManaged var latitude: NSNumber?
    @NSManaged var longitude: NSNumber?
    @NSManaged var rate: NSNumber?

    // MARK: - Protocool MKAnnotation 

    var title: String? {
        if self.rate!.integerValue < 0 {
            return "😒"
        } else if self.rate!.integerValue > 0 {
            return "😀"
        }
        return "😐"
    }
    
    var subtitle: String? {
        return "\(self.rate!)"
    }
    
    var coordinate: CLLocationCoordinate2D {
        return CLLocationCoordinate2D(latitude: self.latitude!.doubleValue , longitude: self.longitude!.doubleValue)
    }
}
