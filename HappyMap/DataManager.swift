//
//  DataManager.swift
//  HappyMap
//
//  Created by Игорь Моренко on 08.02.16.
//  Copyright © 2016 LionSoft LLC. All rights reserved.
//

import UIKit
//import Foundation
import CoreData

class DataManager: NSObject {

    let apikey: String
    let devId: String
    
    let managedObjectContext: NSManagedObjectContext
    
    // Singleton Class
    static let sharedManager = DataManager()
    
    override init() {
        // API Keys
        let apikeys = NSDictionary(contentsOfFile: NSBundle.mainBundle().pathForResource("apikeys", ofType: "plist")!) as! Dictionary<String, String>
        
        // Get api key
        self.apikey = apikeys["api.lion-soft.ru"]!
        //print("API Key: \(apikey)")
        
        // Get device id
        self.devId = UIDevice.currentDevice().identifierForVendor!.UUIDString;
        //print("Device ID: \(devId)")

        //1 Get Context of Core Data
        let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        self.managedObjectContext = appDelegate.managedObjectContext

        super.init()
    }

    //1 Get Context of Core Data
//    var managedObjectContext: NSManagedObjectContext {
//        let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
//        return appDelegate.managedObjectContext
//    }
    
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
    
    func replicationData() {
        
        var results = [Log]()
        
        //2 Find by Location and Category
        let fetchRequest = NSFetchRequest(entityName: "Log")
        fetchRequest.predicate = NSPredicate(format: "fsync == 0")

        //3 Fetch
        do {
            results = try managedObjectContext.executeFetchRequest(fetchRequest) as! [Log]
        } catch let error as NSError {
            print("Error: Could not fetch from Stat: \(error), \(error.userInfo)")
        }
        
        for log in results {
            if doRemoteApi(log) == 1 {
                // Update fsync = 1
                log.fsync = 1
                // Commit
                do {
                    try managedObjectContext.save()
                } catch let error as NSError  {
                    print("Error: Could not save new Log: \(error), \(error.userInfo)")
                }
            }
        }
    }
    
    func doRemoteApi(log: Log) -> Int {
        // Get date
        let date = log.date!.string() //("yyyy-MM-dd HH:mm:ss") "2016-02-08T21:15:30Z"
        print("Date: \(date)")
        
        // Generate apikey
        let sign = self.devId + date + self.apikey
        let md5 = sign.MD5()
        print("apikey=\(md5)")
        
        let apiUrl = "http://api.lionsoft.ru/happymap.php?devid=\(devId)&date=\(date)&lat=xxx&lon=xxx&categ=x&rate=1&apikey=\(md5)"
        print("apiUrl: \(apiUrl)")
        
        return 0
    }
}
