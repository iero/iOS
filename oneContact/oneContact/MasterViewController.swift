//
//  MasterViewController.swift
//  oneContact
//
//  Created by iero on 17/07/2016.
//  Copyright © 2016 Total. All rights reserved.
//

import UIKit
import Kanna

class MasterViewController: UITableViewController, NSXMLParserDelegate {
    var xmlParser: NSXMLParser!
    var personsArray = [PersonItem]()
    var owner = [PersonItem]()
    
    
    // MARK: - Properties
    var detailViewController: DetailViewController? = nil
    let searchController = UISearchController(searchResultsController: nil)
    
    // MARK: - View Setup
    override func viewDidLoad() {
        super.viewDidLoad()
        
        _ = AgilAPI() // Open session
        
        //Load Owner details from plist into Array
//        let path = NSBundle.mainBundle().pathForResource("Owner", ofType: "plist")
//        let dictArray = NSArray(contentsOfFile: path!)
        
        if let plist = Plist(name: "Owner") {
            //Write
//            let dict = plist.getMutablePlistFile()!
//            dict[YearBornKey] = 1979
//            do {
//                try plist.addValuesToPlistFile(dict)
//            } catch {
//                print(error)
//            }
            //print(plist.getValuesInPlistFile())
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
            let o = PersonItem(surname: ownerSurname, name: ownerName, igg: ownerIgg, phoneRig: "", phoneOffice: "", phoneMobile: "", entity: ownerEntity, countryID: "", site: "")
            owner.append(o)

        } else {
            print("Unable to get Owner Plist")
        }
        //for field in dictArray! {
        //}
        
        // Setup the Search Controller
        searchController.searchResultsUpdater = self
        searchController.searchBar.delegate = self
        definesPresentationContext = true
        searchController.dimsBackgroundDuringPresentation = false
        
        // Setup the Scope Bar
        //searchController.searchBar.scopeButtonTitles = ["All", "Explo", "DEV", "Other"]
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
            return personsArray.count
        }
        //return pers.count
        return personsArray.count
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
        
        
        cell.textLabel!.text = personsArray[indexPath.row].getCompleteName()
        cell.detailTextLabel!.text = self.personsArray[indexPath.row].getEntityName()
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
                controller.person = personsArray[indexPath.row]
                controller.navigationItem.leftBarButtonItem = splitViewController?.displayModeButtonItem()
                controller.navigationItem.leftItemsSupplementBackButton = true
            }
        }
    }
    
    func updateSearchResultsForSearchController(searchController: UISearchController)
    {
        // 3 characters minimum
        if searchController.searchBar.text?.characters.count > 2 {
            print("New search : clean table")
            personsArray.removeAll(keepCapacity: false)
            parseAgil(searchController.searchBar.text!)
        }
    }
    /*
    func parseAgilResults(result : String) {
        if let doc = Kanna.HTML(html: result, encoding: NSUTF8StringEncoding) {
            
            var currentSurname = ""
            var currentName = ""
            var currentIGG=""
            
            var currentphoneRIG=""
            var currentphoneOffice=""
            var currentphoneMobile=""
            
            var currentEntity = [String]()
            var currentCountryID = ""
            var currentSite = ""
            
            var person: PersonItem

            for node in doc.xpath("//div[contains(@class,'noResult')]") {
                print(node.content)
            }
            
            for node in doc.xpath("//div/div/div/div[contains(@class,'personfield')] | //div/div/div/div/a[contains(@onclick,'personneSheet')]") {
                
                // New people
                if (node.className == "personfield1") {
                    // Save person before saveing a new one
                    if (personsArray.filter{$0.igg == currentIGG}.count == 0 && !currentIGG.isEmpty && !currentName.isEmpty && !currentSurname.isEmpty) {
                        person = PersonItem(surname: currentSurname, name: currentName, igg: currentIGG, phoneRig: currentphoneRIG, phoneOffice: currentphoneOffice, phoneMobile: currentphoneMobile, entity: currentEntity, countryID: currentCountryID, site: currentSite)
                        self.personsArray += [person]
                    }
                    
                    currentSurname = ""
                    currentName = ""
                    currentIGG=""
                    currentphoneRIG=""
                    currentphoneOffice=""
                    currentphoneMobile=""
                    currentEntity = [String]()
                    currentCountryID = ""
                    currentSite = ""
                }
                
                if (node["onclick"] != nil) {
                    let strnode = node["onclick"]
                    let range = strnode!.startIndex.advancedBy(15) ..< strnode!.startIndex.advancedBy(23)
                    currentIGG = strnode!.substringWithRange(range)
                    //print("[IGG]"+currentIGG)
                } else {
                    let strnode = self.cleanAgilEntry(node.text!)
                    if (!strnode.isEmpty) {
                        if (node.className == "personfield1") { // Name broker
                            //print("Break "+strnode)
                            let sA = strnode.characters.split{$0 == " "}.map(String.init)
                            for s in sA {
                                if (self.checkifLowerCaseIncluded(s)) {
                                    //print("[Name]"+s)
                                    if (currentName == "") {
                                        currentName = s;
                                    } else {
                                        currentName = currentName+" "+s
                                    }
                                } else {
                                    //print("[SurName]"+s)
                                    if (currentSurname == "") {
                                        currentSurname = s;
                                    } else {
                                        currentSurname = currentSurname+" "+s
                                    }
                                    
                                }
                            }
                        } else if (node.className == "personfield3") { // RIG Phone
                            currentphoneRIG=strnode
                        } else if (node.className == "personfield4") { // Office Phone
                            currentphoneOffice=strnode
                        } else if (node.className == "personfieldX") { // Mobile Phone
                            currentphoneMobile=strnode
                        } else if (node.className == "personfield5") { // Entity
                            currentEntity = strnode.characters.split{$0 == "/"}.map(String.init)
                        } else if (node.className == "personfield6") { // country ID
                            currentCountryID=strnode
                        } else if (node.className == "personfield7") { // Site
                            currentSite=strnode
                        } else {
                            print("["+node.className!+"]"+strnode)
                        }
                        
                    }
                }
                
            }
            
        }
    }
    */
    func parseAgil(search :String) {
        
        print("Looking for surnames containing "+search)
        let agil = AgilSearchNames()
        let agilutils = AgilUtils()
        agil.searchSurnames(search) {
            (result: String) in agilutils.parseAgilResults(result)
            dispatch_async(dispatch_get_main_queue(), { () -> Void in
                self.personsArray.sortInPlace({ $0.getNameForListing() < $1.getNameForListing() })
                print(String(self.personsArray.count)+" persons after surname search")
                self.tableView.reloadData()
            })
        }
        /*
        print("Looking for names containing "+search)
        agil.searchNames(search) {
            (resultNames: String) in self.parseAgilResults(resultNames)
            //self.tableView.reloadData()
            dispatch_async(dispatch_get_main_queue(), { () -> Void in
                self.personsArray.sortInPlace({ $0.surname < $1.surname })
                print(String(self.personsArray.count)+" persons after name search")
                self.tableView.reloadData()
            })
        }*/
        
    }
    /*
    func checkifLowerCaseIncluded(text : String) -> Bool{
        let lowerLetterRegEx  = ".*[a-z]+.*"
        let t = NSPredicate(format:"SELF MATCHES %@", lowerLetterRegEx)
        return t.evaluateWithObject(text)
    }
    
    func capitalLettersParts(s: String) -> [Character] {
        return s.characters.filter { ("A"..."Z").contains($0) }
    }
    
    func cleanAgilEntry(string: String) -> String {
        let components = string.componentsSeparatedByCharactersInSet(NSCharacterSet.whitespaceCharacterSet())
        let filtered = components.filter({!$0.isEmpty})
        var result = filtered.joinWithSeparator(" ")
        result = result.stringByReplacingOccurrencesOfString("\"", withString: "", options: NSStringCompareOptions.LiteralSearch, range: nil)
        result = result.stringByReplacingOccurrencesOfString("\t", withString: "", options: NSStringCompareOptions.LiteralSearch, range: nil)
        result = result.stringByReplacingOccurrencesOfString("\n", withString: "", options: NSStringCompareOptions.LiteralSearch, range: nil)
        result = result.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceAndNewlineCharacterSet())
        if (result == ".") {
            return ""
        }
        else {
            return result
        }
    }
    */
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

