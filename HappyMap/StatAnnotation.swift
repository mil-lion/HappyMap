//
//  StatAnnotation.swift
//  HappyMap
//
//  Created by Игорь Моренко on 05.02.16.
//  Copyright © 2016 LionSoft LLC. All rights reserved.
//

import MapKit
import CoreData

class StatAnnotation: NSObject, MKAnnotation {
    let rate: Int
    let category: Int
    let coordinate: CLLocationCoordinate2D
    
    init(category: Int, rate: Int, coordinate: CLLocationCoordinate2D) {
        self.category = category
        self.rate = rate
        self.coordinate = coordinate
        
        super.init()
    }
    
    init(statRec: Stat) {
        let latitude = statRec.latitude!.doubleValue
        let longitude = statRec.longitude!.doubleValue
        self.category = statRec.category!.integerValue
        self.rate = statRec.rate!.integerValue
        self.coordinate = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
        
        super.init()
    }
    
    var title: String? {
        if rate < 0 {
            return "😒"
        } else if rate > 0 {
            return "😀"
        }
        return "😐"
    }
    
    var subtitle: String? {
        return "\(rate)"
    }
    
}

