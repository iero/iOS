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
    let appleProducts = ["Greg Fabre","Yves Le-Stunff","Laurent Castanié","David Campion"]
    var filteredAppleProducts = [String]()
    var resultSearchController = UISearchController()
    
    var xmlParser: NSXMLParser!
    
    struct Item {
        let name: String
        let phone: String
    }
    var items: [Item]!
    
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
            return self.filteredAppleProducts.count
        }
        else
        {
            // no search
            //return self.appleProducts.count
            return 0
        }
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell
    {
        let cell = tableView.dequeueReusableCellWithIdentifier("cell", forIndexPath: indexPath) as UITableViewCell?
        
        if (self.resultSearchController.active)
        {
            cell!.textLabel?.text = self.filteredAppleProducts[indexPath.row]
            
            return cell!
        }
        else
        {
            cell!.textLabel?.text = self.appleProducts[indexPath.row]
            
            return cell!
        }
    }
    
    func updateSearchResultsForSearchController(searchController: UISearchController)
    {
        // 3 characters minimum
        if searchController.searchBar.text?.characters.count > 2 {
            self.filteredAppleProducts.removeAll(keepCapacity: false)
        
            let searchPredicate = NSPredicate(format: "SELF CONTAINS[c] %@", searchController.searchBar.text!)
            let array = (self.appleProducts as NSArray).filteredArrayUsingPredicate(searchPredicate)
            self.filteredAppleProducts = array as! [String]
        
            self.tableView.reloadData()
            parseAgil()
        }
    }
    
    func parseAgil() {
        //let url:NSURL = NSURL(string: "https://itunes.apple.com/search?term=jack+johnson&limit=5")!
        let url:NSURL = NSURL(string: "http://www.iero.org/tmp/agil/original.html")!
        let session = NSURLSession.sharedSession()
        
        let request = NSMutableURLRequest(URL: url)
        request.HTTPMethod = "POST"
        //request.HTTPMethod = "GET"
        request.cachePolicy = NSURLRequestCachePolicy.ReloadIgnoringCacheData
        
        let paramString = "nom=fab"
        request.HTTPBody = paramString.dataUsingEncoding(NSUTF8StringEncoding)
        
        let task = session.dataTaskWithRequest(request) {
            (
            let data, let response, let error) in
            
            guard let _:NSData = data, let _:NSURLResponse = response  where error == nil else {
                print("error")
                return
            }
            let dataString = NSString(data: data!, encoding: NSUTF8StringEncoding)
            //print(dataString)
            
            let html = String(dataString)
    
            if let doc = Kanna.HTML(html: html, encoding: NSUTF8StringEncoding) {
                
                for node in doc.xpath("//div/div/div/div[contains(@class,'personfield')] | //div/div/div/div/a[contains(@onclick,'personneSheet')]") {
                    
                    if (node["onclick"] != nil) {
                        let strnode = node["onclick"]
                        //print(strnode)
                        let range = strnode!.startIndex.advancedBy(15) ..< strnode!.startIndex.advancedBy(23)
                        let igg = strnode!.substringWithRange(range)
                        print("[IGG]"+igg)
                    } else {
                        let s = self.condenseWhitespace(node.text!)
                        if (!s.isEmpty) {
                            print("["+node.className!+"]"+s)
                        }
                    }
                
                }
            
                //a[contains(@onClick,'personneSheet')]
                /*for node in doc.xpath("//div/div/div[contains(@class,'personfield')] | div/a") {
                    //if (node.className == "personfield1"){
                    print(node.text)
                    //print(node["onClick"])
                    //}
                    
                    let s = self.condenseWhitespace(node.text!)
                    if (!s.isEmpty) {
                        
                        print("["+node.className!+"]"+s)
                    }
                }*/
            }
            
        }
        task.resume()
    }
    
    
    func condenseWhitespace(string: String) -> String {
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
