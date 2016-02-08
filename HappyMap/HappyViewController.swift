//
//  HappyViewController.swift
//  HappyMap
//
//  Created by Игорь Моренко on 02.02.16.
//  Copyright © 2016 LionSoft LLC. All rights reserved.
//

import UIKit
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
    
    let dataManager = DataManager.sharedManager

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
            dataManager.saveLog(lat, longitude: long, category: self.category, rate: rate)

            // Change Stat
            // round coordinate
            let statLat = round(lat * kPrecision) / kPrecision
            let statLong = round(long * kPrecision) / kPrecision
            //print("stat coordinate (\(statLat), \(statLong))")
            dataManager.updateStat(statLat, longitude: statLong, category: self.category, rate: rate)
            dataManager.updateStat(statLat, longitude: statLong, category: 0, rate: rate) // Category: Total

            // Replication to site
            dataManager.replicationData()
        } else {
            print("Error finding current location!")
            // TODO: showAlert
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

