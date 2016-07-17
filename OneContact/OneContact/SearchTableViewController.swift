//
//  SearchTableViewController.swift
//  OneContact
//
//  Created by iero on 14/07/2016.
//  Copyright © 2016 Total. All rights reserved.
//

import UIKit
import Kanna

class SearchTableViewController: UITableViewController, UISearchResultsUpdating, NSXMLParserDelegate
{
    var resultSearchController = UISearchController()
    var xmlParser: NSXMLParser!
    
    var personsArray = [PersonItem]()
    let agil = AgilAPI()
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        
        self.resultSearchController = UISearchController(searchResultsController: nil)
        self.resultSearchController.searchResultsUpdater = self
        self.resultSearchController.dimsBackgroundDuringPresentation = false
        self.resultSearchController.searchBar.sizeToFit()
        
        self.tableView.tableHeaderView = self.resultSearchController.searchBar
        
        self.tableView.reloadData()
    }
    
    override func didReceiveMemoryWarning()
    {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: - Table view data source
    
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int
    {
        return 1
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        if (self.resultSearchController.active)
        {
            return self.personsArray.count
        }
        else
        {
            // no search
            //return 0
            return self.personsArray.count
        }
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell
    {
        let cell = tableView.dequeueReusableCellWithIdentifier("cell", forIndexPath: indexPath) as UITableViewCell?
        
        if (self.resultSearchController.active)
        {
            cell!.textLabel?.text = self.personsArray[indexPath.row].getCompleteName()
            return cell!
        }
        else
        {
            cell!.textLabel?.text = self.personsArray[indexPath.row].getCompleteName()
            return cell!
        }
    }
    
    func updateSearchResultsForSearchController(searchController: UISearchController)
    {
        // 3 characters minimum
        if searchController.searchBar.text?.characters.count > 2 {
            print("New search : clean table")
            self.personsArray.removeAll(keepCapacity: false)
            parseAgil(searchController.searchBar.text!)
        }
    }
    
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
    
    func parseAgil(search :String) {
        
        print("Looking for surnames containing "+search)
        agil.searchSurnames(search) {
            (result: String) in self.parseAgilResults(result)
            dispatch_async(dispatch_get_main_queue(), { () -> Void in
                self.personsArray.sortInPlace({ $0.surname < $1.surname })
                self.tableView.reloadData()
            })
        }
        
        print("Looking for names containing "+search)
        agil.searchNames(search) {
            (result: String) in self.parseAgilResults(result)
            //self.tableView.reloadData()
            dispatch_async(dispatch_get_main_queue(), { () -> Void in
                self.personsArray.sortInPlace({ $0.surname < $1.surname })
                self.tableView.reloadData()
            })
        }
        
    }
    
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
    
    
}
