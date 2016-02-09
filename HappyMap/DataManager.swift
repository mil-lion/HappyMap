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
                    print("Error: Could not update Log: \(error), \(error.userInfo)")
                }
            }
        }
    }
    
    // Synchronous Request
    func doRemoteApi(log: Log) -> Int {
        
        var result = 0
        
        if (log.fsync!.integerValue == 1) {
            return result
        }
        
        // data for request
        var params = Dictionary<String, AnyObject>()
        // Get data
        params["devid"] = devId
        params["date"] = log.date!.string() //("yyyy-MM-dd HH:mm:ss") "2016-02-08T21:15:30Z"
        //print("Date: \(params["date"])")
        params["lat"] = log.latitude!.doubleValue
        params["lon"] = log.longitude!.doubleValue
        params["categ"] = log.category!.integerValue
        params["rate"] = log.rate!.integerValue
        // Generate apikey
        params["apikey"] = (self.devId + log.date!.string() + self.apikey).MD5()
        //print("apikey=\(params["apikey"])")
        
        //let apiUrl = "http://happymap.lion-soft.ru/api?devid=\(devId)&date=\(date)&lat=\(lat)&lon=\(lon)&categ=\(categ)&rate=\(rate)&apikey=\(md5)"
        
        let request = NSMutableURLRequest(URL: NSURL(string: "http://happymap.lion-soft.ru/api/")!)
        request.HTTPMethod = "POST"
        do {
            try request.HTTPBody = NSJSONSerialization.dataWithJSONObject(params, options: [])
            //let requesdtJson = NSString(data: request.HTTPBody!, encoding: NSUTF8StringEncoding)
            //print("Request Body: \(requesdtJson!)")
        } catch let err as NSError {
            print("Error: Serialization json request: \(err), \(err.userInfo)")
        }
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.addValue("application/json", forHTTPHeaderField: "Accept")

        let session = NSURLSession.sharedSession()
        
        // set semaphore (for Synchronous Request)
        let sem = dispatch_semaphore_create(0)

        let task1 = session.dataTaskWithRequest(request, completionHandler: { (data: NSData?, response: NSURLResponse?, error: NSError?) -> Void in
            
            if (error == nil) {
                //print("Response: \(response)")
                //let jsonStr = NSString(data: data!, encoding: NSUTF8StringEncoding)
                //print("Body: \(jsonStr)")
                
                do {
                    let jsonData = try NSJSONSerialization.JSONObjectWithData(data!, options: []) as? NSDictionary
                    result = jsonData!["status"] as! Int
                    let msg = jsonData!["msg"] as! String
                    print("Result: \(msg)")

//                    // Update fsync = 1 (for Asynchronous Request)
//                    log.fsync = 1
//                    // Commit
//                    do {
//                        try self.managedObjectContext.save()
//                    } catch let error as NSError  {
//                        print("Error: Could not update Log: \(error), \(error.userInfo)")
//                    }
                } catch let err as NSError {
                    let jsonStr = NSString(data: data!, encoding: NSUTF8StringEncoding)
                    print("Error could not parse JSON: \(jsonStr)")
                    print("Error: DeSerialization json response: \(err), \(err.userInfo)")
                }
            } else {
                print("Error: Could not request api: \(error!), \(error!.userInfo)")
            }
                        
            // delete semophore (for Synchronous Request)
            dispatch_semaphore_signal(sem)
        })
        // run parallel thread
        task1.resume()
        
        // white delete semophore (for Synchronous Request)
        dispatch_semaphore_wait(sem, DISPATCH_TIME_FOREVER)

        return result
    }
}
