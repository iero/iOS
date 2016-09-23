//
//  MasterViewController.swift
//  oneContact
//
//  Created by iero on 17/07/2016.
//  Copyright © 2016 Total. All rights reserved.
//

import UIKit
import Kanna
import MessageUI

class MasterViewController: UITableViewController, NSXMLParserDelegate, MFMailComposeViewControllerDelegate {
    var xmlParser: NSXMLParser!
    var owner = [PersonItem]()
    
    var filteredArray = [PersonItem]() // Already search data
    //var personsArray = [PersonItem]() // People stored localy
    //var baseArray = [PersonItem]() // Saved database
    
    @IBOutlet weak var options: UIBarButtonItem!
    
    @IBAction func sendEmail(sender: UIButton) {
        //Check to see the device can send email.
        if( MFMailComposeViewController.canSendMail() ) {
            print("Can send email.")
            
            let mailComposer = MFMailComposeViewController()
            mailComposer.mailComposeDelegate = self
            
            //Set the subject and message of the email
            mailComposer.setSubject("Have you heard a swift?")
            mailComposer.setMessageBody("This is what they sound like.", isHTML: false)
            
            if let filePath = NSBundle.mainBundle().pathForResource("Employees", ofType: "plist") {
                print("File path loaded.")
                
                if let fileData = NSData(contentsOfFile: filePath) {
                    print("File data loaded.")
                    mailComposer.addAttachmentData(fileData, mimeType: "application/xml", fileName: "Employees.plist")
                }
            }
            self.presentViewController(mailComposer, animated: true, completion: nil)
        }
    }
    
    func mailComposeController(controller: MFMailComposeViewController, didFinishWithResult result: MFMailComposeResult, error: NSError?) {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    
    // MARK: - Properties
    var detailViewController: DetailViewController? = nil
    let searchController = UISearchController(searchResultsController: nil)
   
    // MARK: - View Setup
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Load owner of software
        // Todo  : Call for details if file doesn't exists
        if let plist = Plist(name: "Owner") {
            var ownerSurname=""
            var ownerName=""
            var ownerIgg=""
            var ownerEntity=""
            
            for p in plist.getValuesInPlistFile()! {
                let key = p.key as! String
                let val = p.value as! String
                if key == "surname" {
                    ownerSurname = val
                } else if key == "name" {
                    ownerName = val
                } else if key == "igg" {
                    ownerIgg = val
                } else if key == "entity" {
                    ownerEntity = val
                }
            }
            let o = PersonItem(surname: ownerSurname, name: ownerName, igg: ownerIgg, entity: ownerEntity)
            owner.append(o)

        } else {
            print("Unable to get Owner Plist")
        }
        
        /* Load local list */
        
        let ownKey = PlistManager.sharedInstance.getValueForKey("J0235385")
        print(ownKey)
        
        //baseArray = PlistManager.sharedInstance.loadUsers()
        
        // Setup the Search Controller
        searchController.searchResultsUpdater = self
        searchController.searchBar.delegate = self
        definesPresentationContext = true
        searchController.dimsBackgroundDuringPresentation = false
        
        tableView.tableHeaderView = searchController.searchBar
        
        if let splitViewController = splitViewController {
            let controllers = splitViewController.viewControllers
            detailViewController = (controllers[controllers.count-1] as! UINavigationController).topViewController as? DetailViewController
        }
    }
    
    override func viewWillAppear(animated: Bool) {
        clearsSelectionOnViewWillAppear = splitViewController!.collapsed
        super.viewWillAppear(animated)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    // MARK: - Table View
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if searchController.active && searchController.searchBar.text != "" {
            //return filteredCandies.count
            return filteredArray.count
        }
        //return pers.count
        return filteredArray.count
        //return 0
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("Cell", forIndexPath: indexPath)
        /*let candy: People
        if searchController.active && searchController.searchBar.text != "" {
            candy = filteredCandies[indexPath.row]
        } else {
            candy = candies[indexPath.row]
        }*/
        
        //var iconImage : UIImage
/*        let iconImage = FGInitialCircleImage.circleImage("John", lastName: "Appleseed", size: cell.imageView!.frame.size.width, borderWidth: 5, borderColor: UIColor.clearColor(), backgroundColor: UIColor.blueColor(), textColor: UIColor.whiteColor());*/
        
/*        let imageName = "logo.jpg"
        let image = UIImage(named: imageName)
        let newImage = resizeImage(image!, toTheSize: CGSizeMake(70, 70))
        var cellImageLayer: CALayer?  = cell.imageView!.layer
        cellImageLayer!.cornerRadius = cellImageLayer!.frame.size.width / 2
        cellImageLayer!.masksToBounds = true
        cell.imageView!.image = newImage*/
        
        
        
        //let image : UIImage = UIImage(named: "osx_design_view_messages")!
        //println("The loaded image: \(image)")
//        cell.imageView!.image = iconImage

        
        cell.textLabel!.text = filteredArray[indexPath.row].getCompleteName()
        cell.detailTextLabel!.text = self.filteredArray[indexPath.row].getEntityName()
        return cell
    }
    
    func filterContentForSearchText(searchText: String, scope: String = "All") {
        /*filteredCandies = candies.filter({( candy : People) -> Bool in
            let categoryMatch = (scope == "All") || (candy.category == scope)
            return categoryMatch && candy.name.lowercaseString.containsString(searchText.lowercaseString)
        })*/
        tableView.reloadData()
    }
    
    // MARK: - Segues
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "showDetail" {
            if let indexPath = tableView.indexPathForSelectedRow {
                /*let candy: People
                if searchController.active && searchController.searchBar.text != "" {
                    candy = filteredCandies[indexPath.row]
                } else {
                    candy = candies[indexPath.row]
                }*/
                
                let controller = (segue.destinationViewController as! UINavigationController).topViewController as! DetailViewController
                //controller.detailCandy = candy
                controller.person = filteredArray[indexPath.row]
                controller.navigationItem.leftBarButtonItem = splitViewController?.displayModeButtonItem()
                controller.navigationItem.leftItemsSupplementBackButton = true
            }
        }
    }
    func searchBarSearchButtonClicked(searchBar: UISearchBar) {
        print("Search button hit")
    }
    
    
    func updateSearchResultsForSearchController(searchController: UISearchController)
    {
        // 3 characters minimum
        if searchController.searchBar.text?.characters.count > 2 {
            // Wait to call
            let debouncedFunction = Debouncer(delay: 0.25) {
                self.searchItems()
            }
            debouncedFunction.call()
        } else {
            filteredArray.removeAll(keepCapacity: false)
            self.tableView.reloadData()
        }
    }

    func searchItems() {
        NSLog("New search : clean table")
        filteredArray.removeAll(keepCapacity: false)
        
        let searchText = searchController.searchBar.text?.lowercaseString
        
        /*filteredArray=self.baseArray.filter() {
            ($0.surname.lowercaseString as NSString).containsString(searchText!)
        }*/
        
        //self.filteredArray.sortInPlace({ $0.getNameForListing() < $1.getNameForListing() })
        //self.tableView.reloadData()
        
        let agil = AgilAPI()
        agil.searchSurnames("*"+searchText!+"*") {
            (completionSurnames: [PersonItem]) in //agilutils.parseAgilResults(result)
            dispatch_async(dispatch_get_main_queue(), { () -> Void in
                NSLog(String(completionSurnames.count)+" persons after surname search")
                for p in completionSurnames {
                    if (self.self.filteredArray.filter{$0.igg == p.igg}.count == 0) {
                        self.self.filteredArray.append(p)
                    }
                    /*if (self.baseArray.filter{$0.igg == p.igg}.count == 0) {
                        let dict = ["surname": p.surname, "name": p.name, "entity" : p.getEntityName()]
                        PlistManager.sharedInstance.addNewItemWithKey(p.igg, value: dict)
                        self.baseArray.append(p)
                    }*/
                }
                /*self.filteredArray=self.baseArray.filter() {
                    ($0.surname.lowercaseString as NSString).containsString(searchText!)
                }*/
                self.filteredArray.sortInPlace({ $0.getNameForListing() < $1.getNameForListing() })
                self.tableView.reloadData()
            })
        }
        
        /*
        agil.searchNames("*"+searchText!+"*") {
            (completionSurnames: [PersonItem]) in //agilutils.parseAgilResults(result)
            dispatch_async(dispatch_get_main_queue(), { () -> Void in
                NSLog(String(completionSurnames.count)+" persons after name search")
                for p in completionSurnames {
                    if (self.self.filteredArray.filter{$0.igg == p.igg}.count == 0) {
                        self.self.filteredArray.append(p)
                    }
                }
                self.filteredArray.sortInPlace({ $0.getNameForListing() < $1.getNameForListing() })
                self.tableView.reloadData()
            })
        }*/
        
    }
    
} // end of class

func debounce( delay:NSTimeInterval, queue:dispatch_queue_t, action: (()->()) ) -> ()->() {
    var lastFireTime:dispatch_time_t = 0
    let dispatchDelay = Int64(delay * Double(NSEC_PER_SEC))
    
    return {
        lastFireTime = dispatch_time(DISPATCH_TIME_NOW,0)
        dispatch_after(
            dispatch_time(
                DISPATCH_TIME_NOW,
                dispatchDelay
            ),
            queue) {
                let now = dispatch_time(DISPATCH_TIME_NOW,0)
                let when = dispatch_time(lastFireTime, dispatchDelay)
                if now >= when {
                    action()
                }
        }
    }

}

extension MasterViewController: UISearchBarDelegate {
    // MARK: - UISearchBar Delegate
    func searchBar(searchBar: UISearchBar, selectedScopeButtonIndexDidChange selectedScope: Int) {
        filterContentForSearchText(searchBar.text!, scope: searchBar.scopeButtonTitles![selectedScope])
    }
}

extension MasterViewController: UISearchResultsUpdating {
    // MARK: - UISearchResultsUpdating Delegate
    /*func updateSearchResultsForSearchController(searchController: UISearchController) {
        let searchBar = searchController.searchBar
        let scope = searchBar.scopeButtonTitles![searchBar.selectedScopeButtonIndex]
        filterContentForSearchText(searchController.searchBar.text!, scope: scope)
    }*/
}

