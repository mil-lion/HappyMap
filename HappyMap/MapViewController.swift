//
//  MapViewController.swift
//  HappyMap
//
//  Created by Игорь Моренко on 02.02.16.
//  Copyright © 2016 LionSoft LLC. All rights reserved.
//

import UIKit
import MapKit
import CoreLocation
import CoreData

class Annotation: NSObject, MKAnnotation {
    let rate: Int
    let category: Int
    let coordinate: CLLocationCoordinate2D
    
    init(category: Int, rate: Int, coordinate: CLLocationCoordinate2D) {
        self.category = category
        self.rate = rate
        self.coordinate = coordinate
        
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

let kRegionRadius: CLLocationDistance = 1000 // in meter

class MapViewController: UIViewController, MKMapViewDelegate, CLLocationManagerDelegate {

    @IBOutlet weak var mapView: MKMapView!

    let locationManager = CLLocationManager()

    func checkLocationAuthorizationStatus() {
        if #available(iOS 8.0, *) {
            // Ask for Authorisation from the User.
            if CLLocationManager.authorizationStatus() == .AuthorizedAlways {
                mapView.showsUserLocation = true
                return
            } else {
                locationManager.requestAlwaysAuthorization()
            }
//            // For use in foreground
//            if CLLocationManager.authorizationStatus() == .AuthorizedWhenInUse {
//                mapView.showsUserLocation = true
//            } else {
//                locationManager.requestWhenInUseAuthorization()
//            }
        } else {
            // Fallback on earlier versions
            mapView.showsUserLocation = true
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        locationManager.delegate = self
        checkLocationAuthorizationStatus()
        locationManager.startUpdatingLocation()
        
        // set initial location in Honolulu
        //let initialLocation = CLLocation(latitude: 21.282778, longitude: -157.829444)
        //centerMapOnLocation(initialLocation)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        //1 Get Context of Core Data
        let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        let managedContext = appDelegate.managedObjectContext
        
        //2 Find by Category = Total (0)
        let fetchRequest = NSFetchRequest(entityName: "Stat")
        // where
        fetchRequest.predicate = NSPredicate(format: "category = 0")
        // order by
        //let sortDescriptor = NSSortDescriptor(key: "date", ascending: false)
        //fetchRequest.sortDescriptors = [sortDescriptor]
        
        //3 Fetch
        do {
            let results = try managedContext.executeFetchRequest(fetchRequest) as! [NSManagedObject]
            updateStatAnnotations(results)
        } catch let error as NSError {
            print("Could not fetch \(error), \(error.userInfo)")
        }
        
        centerMapOnLocation(mapView.userLocation.location)
    }

    func updateStatAnnotations(stats: [NSManagedObject]) {
        // remove all Annotations
        let allAnnotations = self.mapView.annotations
        self.mapView.removeAnnotations(allAnnotations)
        // add Annotations
        for statRec in stats {
            let latitude = statRec.valueForKey("latitude") as! Double
            let longitude = statRec.valueForKey("longitude") as! Double
            let category = statRec.valueForKey("category") as! Int
            let rate = statRec.valueForKey("rate") as! Int
            let coordinate = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
            
            let statAnnotation = Annotation(category: category, rate: rate, coordinate: coordinate)
            mapView.addAnnotation(statAnnotation)
        }
    }
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

    // MARK: Other mapview functions
    
    func centerMapOnLocation(location: CLLocation?) {
        if let coordinate = location?.coordinate {
            let coordinateRegion = MKCoordinateRegionMakeWithDistance(coordinate, kRegionRadius * 2.0, kRegionRadius * 2.0)
            mapView.setRegion(coordinateRegion, animated: true)
        }
    }

    @IBAction func zoomToCurrentLocation(sender: AnyObject) {
        centerMapOnLocation(mapView.userLocation.location)
    }

    // MARK: - MKMapViewDelegate
    
    func mapView(mapView: MKMapView, viewForAnnotation annotation: MKAnnotation) -> MKAnnotationView? {
        let identifier = "myPin"
        if let annotation  = annotation as? Annotation {
            var annotationView = mapView.dequeueReusableAnnotationViewWithIdentifier(identifier) as? MKPinAnnotationView
            if annotationView == nil {
                annotationView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: identifier)
                annotationView?.canShowCallout = true
            } else {
                annotationView?.annotation = annotation
            }
            // change pin color
            if #available(iOS 9.0, *) {
                if annotation.rate < 0 {
                    annotationView?.pinTintColor = MKPinAnnotationView.redPinColor()
                } else if annotation.rate > 0 {
                    annotationView?.pinTintColor = MKPinAnnotationView.greenPinColor()
                } else {
                    annotationView?.pinTintColor = MKPinAnnotationView.purplePinColor()
                }
            } else {
                // Fallback on earlier versions
                if annotation.rate < 0 {
                    annotationView?.pinColor = .Red
                } else if annotation.rate > 0 {
                    annotationView?.pinColor = .Green
                } else {
                    annotationView?.pinColor = .Purple
                }
            }
            return annotationView
        }
        return nil
    }
    
    // MARK: - CLLocationManagerDelegate
    
    func locationManager(manager: CLLocationManager, didChangeAuthorizationStatus status: CLAuthorizationStatus) {
        print("didChangeAuthorizationStatus: \(status)")
        if #available(iOS 8.0, *) {
            mapView.showsUserLocation = (status == .AuthorizedAlways || status == .AuthorizedWhenInUse)
        } else {
            // Fallback on earlier versions
            mapView.showsUserLocation = (status == .Restricted);
        }
    }
    
    func locationManager(manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        //print("Current location \(locations.last)")
        manager.stopUpdatingLocation()
        centerMapOnLocation(locations.last)
    }

    func locationManager(manager: CLLocationManager, didFailWithError error: NSError) {
        print("Error location: \(error.localizedDescription)")
    }
}
