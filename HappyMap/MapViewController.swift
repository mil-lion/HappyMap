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

let kRegionRadius: CLLocationDistance = 1000 // in meter

class MapViewController: UIViewController, MKMapViewDelegate, CLLocationManagerDelegate, NSFetchedResultsControllerDelegate {

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

    var frc: NSFetchedResultsController!;
    
    //1 Get Context of Core Data
    var managedObjectContext: NSManagedObjectContext {
        let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        return appDelegate.managedObjectContext
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.

        // Fetched Results Controller init
        //2 Find by Category = Total (0)
        let fetchRequest = NSFetchRequest(entityName: "Stat")
        // where
        fetchRequest.predicate = NSPredicate(format: "category = 0")
        // order by
        let sortDescriptor = NSSortDescriptor(key: "rate", ascending: true)
        fetchRequest.sortDescriptors = [sortDescriptor]
        
        frc = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: managedObjectContext, sectionNameKeyPath: nil, cacheName: nil)
        frc.delegate = self

        //3 Fetch
        do {
            try frc.performFetch()
            //print("Successfully fetched")
            configureAnnotations()
        } catch let error as NSError {
            print("Could not fetch \(error), \(error.userInfo)")
        }

        // location manager init
        if CLLocationManager.locationServicesEnabled() {
            locationManager.delegate = self
            checkLocationAuthorizationStatus()
            locationManager.startUpdatingLocation()
        } else {
            print("Error: Location service disabled");
            // TODO: showAlert
        }
        
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
        
        centerMapOnLocation(mapView.userLocation.location)
    }

    func configureAnnotations() {
        // remove all Annotations
        let allAnnotations = self.mapView.annotations
        self.mapView.removeAnnotations(allAnnotations)
        // add Annotations
        let annotations = self.frc.fetchedObjects as! [Stat]
        self.mapView.addAnnotations(annotations)
    }
    
    // MARK: - Fetched Results Controller Delegate
    
    func controllerWillChangeContent(controller: NSFetchedResultsController) {
        
        UIApplication.sharedApplication().networkActivityIndicatorVisible = true;
    }
    
    func controller(controller: NSFetchedResultsController, didChangeObject anObject: AnyObject, atIndexPath indexPath: NSIndexPath?, forChangeType type: NSFetchedResultsChangeType, newIndexPath: NSIndexPath?) {

        switch type {
        case .Insert:
            self.mapView.addAnnotation(anObject as! Stat)
            break;
        
        case .Update:
            self.mapView.removeAnnotation(anObject as! Stat)
            self.mapView.addAnnotation(anObject as! Stat)
            break;
        
        case .Delete:
            self.mapView.removeAnnotation(anObject as! Stat)
            break;
        
        case .Move:
            // do nothing
            break;
        }
    }
    
    func controllerDidChangeContent(controller: NSFetchedResultsController) {

        UIApplication.sharedApplication().networkActivityIndicatorVisible = false;
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
        if let annotation  = annotation as? Stat {
            var annotationView = mapView.dequeueReusableAnnotationViewWithIdentifier(identifier) as? MKPinAnnotationView
            if annotationView == nil {
                annotationView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: identifier)
                annotationView!.canShowCallout = true
            } else {
                annotationView!.annotation = annotation
            }
            // change pin color
            let rate = annotation.rate!.integerValue
            if #available(iOS 9.0, *) {
                if rate < 0 {
                    annotationView!.pinTintColor = MKPinAnnotationView.redPinColor()
                } else if rate > 0 {
                    annotationView!.pinTintColor = MKPinAnnotationView.greenPinColor()
                } else {
                    annotationView!.pinTintColor = MKPinAnnotationView.purplePinColor()
                }
            } else {
                // Fallback on earlier versions
                if rate < 0 {
                    annotationView!.pinColor = .Red
                } else if rate > 0 {
                    annotationView!.pinColor = .Green
                } else {
                    annotationView!.pinColor = .Purple
                }
            }
            return annotationView
        }
        return nil
    }
    
    // MARK: - CLLocationManagerDelegate
    
    func locationManager(manager: CLLocationManager, didChangeAuthorizationStatus status: CLAuthorizationStatus) {
        //print("didChangeAuthorizationStatus: \(status)")
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
        print("Error finding location: \(error.localizedDescription)")
    }
}
