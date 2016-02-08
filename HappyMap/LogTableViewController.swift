//
//  LogTableViewController.swift
//  HappyMap
//
//  Created by Игорь Моренко on 03.02.16.
//  Copyright © 2016 LionSoft LLC. All rights reserved.
//

import UIKit
import CoreData

class LogTableViewController: UITableViewController, NSFetchedResultsControllerDelegate {

    var frc: NSFetchedResultsController!;
    
    //1 Get Context of Core Data
    var managedObjectContext: NSManagedObjectContext {
        let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        return appDelegate.managedObjectContext
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        //barButtonAddPerson = UIBarButtonItem(barButtonSystemItem: .Add,
        //    target: self,
        //    action: "addNewPerson:")

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem()
        // self.navigationItem.leftBarButtonItem = editButtonItem()
        // self.navigationItem.rightBarButtonItem = barButtonAddPerson
        
        // Fetched Results Controller init
        // fetch request init for entity Log
        let fetchRequest = NSFetchRequest(entityName: "Log")
        // order by
        let sortDescriptor = NSSortDescriptor(key: "date", ascending: false)
        fetchRequest.sortDescriptors = [sortDescriptor]
        
        frc = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: managedObjectContext, sectionNameKeyPath: nil, cacheName: nil)
        frc.delegate = self

        //3 Fetch
        do {
            try frc.performFetch()
            //print("Successfully fetched")
        } catch let error as NSError {
            print("Could not fetch \(error), \(error.userInfo)")
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    /*
    func addNewPerson(sender: AnyObject){
        /* This is a custom segue identifier that we have defined in our
        storyboard that simply does a "Show" segue from our view controller
        to the "Add New Person" view controller */
        performSegueWithIdentifier("addPerson", sender: nil)
    }
    */

    // MARK: - Fetched Results Controller Delegate
    
    func controllerWillChangeContent(controller: NSFetchedResultsController) {
        tableView.beginUpdates()
    }
    
    func controller(controller: NSFetchedResultsController, didChangeObject anObject: AnyObject, atIndexPath indexPath: NSIndexPath?, forChangeType type: NSFetchedResultsChangeType, newIndexPath: NSIndexPath?) {
        
        if type == .Delete {
            
            tableView.deleteRowsAtIndexPaths([indexPath!], withRowAnimation: .Automatic)
        }
        else if type == .Insert {
            
            tableView.insertRowsAtIndexPaths([newIndexPath!], withRowAnimation: .Automatic)
        }
    }
    
    func controllerDidChangeContent(controller: NSFetchedResultsController) {
        tableView.endUpdates()
    }
    
    // MARK: - Table view data source

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {

        return frc.sections!.count
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        let sectionInfo = frc.sections![section] as NSFetchedResultsSectionInfo
        return sectionInfo.numberOfObjects
    }

    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("Cell", forIndexPath: indexPath)

        // Configure the cell...
        let logRec = frc.objectAtIndexPath(indexPath) as! Log
        
        let smile = (logRec.rate!.integerValue > 0 ? "😀" : "😡");
        cell.textLabel!.text = "\(smile) : \(logRec.category!)"
        cell.detailTextLabel!.text = "\(logRec.date!.string()) (\(logRec.latitude!), \(logRec.longitude!))"

        return cell
    }

    /*
    // Override to support conditional editing of the table view.
    override func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    */

    /*
    // Override to support editing the table view.
    override func setEditing(editing: Bool, animated: Bool) {
        super.setEditing(editing, animated: animated)
    
        if editing {
            navigationItem.setRightBarButtonItem(nil, animated: true)
        } else {
            navigationItem.setRightBarButtonItem(barButtonAddPerson, animated: true)
        }
    
    }
    */
    
    /*
    // Override to support editing the table view.
    override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        if editingStyle == .Delete {
            // Delete the row from the data source
            tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Fade)
        } else if editingStyle == .Insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    

        let personToDelete = self.frc.objectAtIndexPath(indexPath) as! Person
    
        managedObjectContext!.deleteObject(personToDelete)
    
        if personToDelete.deleted{
    
            do {
                try managedObjectContext!.save()
                print("Successfully deleted the object")
            } catch let error as NSError {
                print("Failed to save the context with error = \(error)")
            }
        }
    }
    */

    /*
    // Override to support editing the table view.
    override func tableView(tableView: UITableView, editingStyleForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCellEditingStyle {
            return .Delete
    }
    */
    
    /*
    // Override to support rearranging the table view.
    override func tableView(tableView: UITableView, moveRowAtIndexPath fromIndexPath: NSIndexPath, toIndexPath: NSIndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(tableView: UITableView, canMoveRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    */

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
