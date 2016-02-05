//
//  HappyViewController.swift
//  HappyMap
//
//  Created by Игорь Моренко on 02.02.16.
//  Copyright © 2016 LionSoft LLC. All rights reserved.
//

import UIKit
import CoreData
import CoreLocation

let kPrecision = 10000.0
// Градусы   Дистанция
// --------- ----------
// 1         111 km
// 0.1       11.1 km
// 0.01      1.11 km
// 0.001     111 m
//*0.0001    11.1 m
// 0.00001   1.11 m
// 0.000001  11.1 cm

class HappyViewController: UIViewController, CLLocationManagerDelegate {

    let locationManager = CLLocationManager()

    var location: CLLocation? = nil
    var category: Int = 1

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view, typically from a nib.
        
        // location manager defined
        if CLLocationManager.locationServicesEnabled() {
            locationManager.delegate = self
            //locationManager.desiredAccuracy = kCLLocationAccuracyHundredMeters
            //locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters
            //checkLocationAuthorizationStatus
            if #available(iOS 8.0, *) {
                // Ask for Authorisation from the User.
                locationManager.requestAlwaysAuthorization()
                // For use in foreground
                //locationManager.requestWhenInUseAuthorization()
            } else {
                // Fallback on earlier versions
            }
//            if #available(iOS 9.0, *) {
//                locationManager.requestLocation()
//            } else {
//                // Fallback on earlier versions
//                locationManager.startUpdatingLocation()
//            }
            locationManager.startUpdatingLocation()
        } else {
            print("Error: Location service disabled");
            // TODO: showAlert
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func HappyPress(sender: AnyObject) {
        print("😀 Happy press!")
        changeRate(+1)
    }

    @IBAction func SadPress(sender: AnyObject) {
        print("😒 Sad press!")
        changeRate(-1)
    }
    
    func changeRate(rate: Int) {
        
        //print(rate)
        // Change Background Color or Background Image
        self.view.backgroundColor = (rate > 0 ? UIColor.greenColor() : UIColor.redColor())
        
        // choose category
        // TODO:
        
        // current location
        if let coordinate = self.location?.coordinate {
            //print("Current location: \(location)")
            
            let lat = coordinate.latitude
            let long = coordinate.longitude
            
            // Save to Log
            saveLog(lat, longitude: long, category: self.category, rate: rate)
            
            // Change Stat
            // round coordinate
            let statLat = round(lat * kPrecision) / kPrecision
            let statLong = round(long * kPrecision) / kPrecision
            //print("stat coordinate (\(statLat), \(statLong))")
            updateStat(statLat, longitude: statLong, category: self.category, rate: rate)
            updateStat(statLat, longitude: statLong, category: 0, rate: rate) // Category: Total
        } else {
            print("Error finding current location!")
            // TODO: showAlert
        }
        
    }
    
    //1 Get Context of Core Data
    var managedObjectContext: NSManagedObjectContext {
        let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        return appDelegate.managedObjectContext
    }

    func saveLog(latitude: Double, longitude: Double, category: Int, rate: Int) {
        
        //2 New Entry Object
        //let entityLog =  NSEntityDescription.entityForName("Log", inManagedObjectContext: managedContext)
        //let logItem = NSManagedObject(entity: entityLog!, insertIntoManagedObjectContext: managedContext)
        let newLog = NSEntityDescription.insertNewObjectForEntityForName("Log", inManagedObjectContext: managedObjectContext) as! Log
        
        //3 Set Object Attribute
        newLog.date = NSDate()
        newLog.latitude = latitude
        newLog.longitude = longitude
        newLog.category = category
        newLog.rate = rate
        newLog.fsync = 0
        
        //4 Commit
        do {
            try managedObjectContext.save()
            //5 Refresh Data
            //logItems.append(logItem)
        } catch let error as NSError  {
            print("Error: Could not save new Log: \(error), \(error.userInfo)")
        }
    }
    
    func updateStat(latitude: Double, longitude: Double, category: Int, rate: Int) {
        
        var statRec: Stat? = nil
        
        //2 Find by Location and Category
        let fetchRequest = NSFetchRequest(entityName: "Stat")
        //where
//        var predicates = [NSPredicate]()
//        predicates.append(NSPredicate(format: "latitude = %@", latitude))
//        predicates.append(NSPredicate(format: "longitude = %@", longitude))
//        predicates.append(NSPredicate(format: "category = %@", category as NSObject))
//        let compoundPredicate = NSCompoundPredicate(andPredicateWithSubpredicates: predicates)
//        print(compoundPredicate)
//        fetchRequest.predicate = compoundPredicate
        let predicate = NSPredicate(format: "latitude = %@ AND longitude = %@ AND category = %@",
            argumentArray: [latitude, longitude, category])
        //print(predicate)
        fetchRequest.predicate = predicate
        
        //3 Fetch
        do {
            let results = try managedObjectContext.executeFetchRequest(fetchRequest) as! [Stat]
            statRec = results.first
        } catch let error as NSError {
            print("Error: Could not fetch from Stat: \(error), \(error.userInfo)")
        }
        
        //4 Update or Insert
        if statRec != nil {
            //4 Update Item
            statRec!.rate = statRec!.rate!.integerValue + rate
            //print("Update Satat: \(statRate + rate)")
        } else {
            //4 New Item
            //let entityStat =  NSEntityDescription.entityForName("Stat", inManagedObjectContext: managedContext)
            //statRec = NSManagedObject(entity: entityStat!, insertIntoManagedObjectContext: managedContext)
            statRec = NSEntityDescription.insertNewObjectForEntityForName("Stat", inManagedObjectContext: managedObjectContext) as? Stat
            
            statRec!.latitude = latitude
            statRec!.longitude = longitude
            statRec!.category = category
            statRec!.rate = rate
        }
        
        //5 Commit
        do {
            try managedObjectContext.save()
            //5 Refresh Data
            print("Save stat: \(statRec!.rate!) for category: \(category)")
            //statItems.append(logItem)
        } catch let error as NSError  {
            print("Error: Could not save Stat: \(error), \(error.userInfo)")
        }
    }

    // MARK: - CLLocationManagerDelegate
    
    func locationManager(manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        //print("Current location.first: \(locations.first)")
        //if locations.count > 1 { print("Current location.last: \(locations.last)") }
        if let location = locations.last {
            self.location = location
        }
        //manager.stopUpdatingLocation()
    }
    
    func locationManager(manager: CLLocationManager, didFailWithError error: NSError) {
        print("Error finding location: \(error.localizedDescription)")
    }
}

