//
//  MasterViewController.swift
//  SearchbarTutorial
//
//  Created by Marco Aurelio Viana Almeida on 12/16/15.
//  Copyright © 2015 appscg.com. All rights reserved.
//

import UIKit

class MasterViewController: UITableViewController {

    var detailViewController: DetailViewController? = nil
    var carsArray = [Car]()


    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        if let split = self.splitViewController {
            let controllers = split.viewControllers
            self.detailViewController = (controllers[controllers.count-1] as! UINavigationController).topViewController as? DetailViewController
        }
        
        //Load Cars from plist into Array
        let path = NSBundle.mainBundle().pathForResource("Cars", ofType: "plist")
        let dictArray = NSArray(contentsOfFile: path!)
        
        for carItem in dictArray! {
            let newCar : Car = Car(type:(carItem.objectForKey("type")) as! String, maker: (carItem.objectForKey("maker")) as! String, model: (carItem.objectForKey("model")) as! String, image: (carItem.objectForKey("image")) as! String)
            carsArray.append(newCar)
        }
    }

    override func viewWillAppear(animated: Bool) {
        self.clearsSelectionOnViewWillAppear = self.splitViewController!.collapsed
        super.viewWillAppear(animated)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

   
    // MARK: - Table View

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return carsArray.count
    }

    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("Cell", forIndexPath: indexPath)

        let car = carsArray[indexPath.row]
        cell.textLabel!.text = car.model
        cell.detailTextLabel?.text = car.maker
        return cell
    }
    
    // MARK: - Segues

    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "showDetail" {
            if let indexPath = self.tableView.indexPathForSelectedRow {
                let carDetail : Car = carsArray[indexPath.row]
                let controller = (segue.destinationViewController as! UINavigationController).topViewController as! DetailViewController
                controller.carDetail = carDetail
                controller.navigationItem.leftBarButtonItem = self.splitViewController?.displayModeButtonItem()
                controller.navigationItem.leftItemsSupplementBackButton = true
            }
        }
    }
}

