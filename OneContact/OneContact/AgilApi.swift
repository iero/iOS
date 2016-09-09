//
//  AgilAPI.swift
//  oneContact
//
//  Created by iero on 17/07/2016.
//  Copyright © 2016 Total. All rights reserved.
//

import Foundation
import Kanna

class AgilAPI {
    
    let baseUrl = NSURL(string: "http://agil.corp.local/agil/personne.view?actionaig=init")!
    let searchUrl = NSURL(string: "http://agil.corp.local/agil/personne.view")!
    
    var owner : PersonItem?
    
    init() {
        print("Initiate Agil connection")
        
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
            owner = PersonItem(surname: ownerSurname, name: ownerName, igg: ownerIgg, entity: ownerEntity)
        } else {
            print("Unable to get Owner Plist")
        }
        
        let s = NSURLSession.sharedSession()
        let task = s.dataTaskWithURL(baseUrl) {
            (let data, let response, let error) in
            guard let _:NSData = data, let _:NSURLResponse = response  where error == nil else {
                print("Error fetching page")
                return
            }
            /*if let httpResponse = response as? NSHTTPURLResponse {
             print(httpResponse.statusCode)
             }*/
            //self.setCookies(response!)    //debug
            //let dataString = NSString(data: data!, encoding: NSUTF8StringEncoding)
            //let dataString = NSString(data: data!, encoding: NSASCIIStringEncoding)
            //print(dataString)
        }
        task.resume()
    }
    
    
    func searchNames(str : String, completionNames : [PersonItem] ->  ()) {
        let request = NSMutableURLRequest(URL: searchUrl)
        request.HTTPMethod = "POST"
        request.cachePolicy = NSURLRequestCachePolicy.ReloadIgnoringCacheData
        
        let paramString = "actionaig=find&prenom="+str
        //request.HTTPBody = paramString.dataUsingEncoding(NSUTF8StringEncoding)
        request.HTTPBody = paramString.dataUsingEncoding(NSASCIIStringEncoding)
        
        
        let s = NSURLSession.sharedSession()
        let task = s.dataTaskWithRequest(request) {
            (let data, let response, let error) in
            guard let _:NSData = data, let _:NSURLResponse = response  where error == nil else {
                print("Error fetching page")
                return
            }
            /*if let httpResponse = response as? NSHTTPURLResponse {
             print(httpResponse.statusCode)
             }*/
            //self.setCookies(response!) //debut
            // let dataString = NSString(data: data!, encoding: NSUTF8StringEncoding)
            let dataString = NSString(data: data!, encoding: NSASCIIStringEncoding)
            //print(dataString)
            completionNames(self.parseAgilResults(String(dataString)))
        }
        task.resume()
    }
    
    func searchSurnames(str : String, completionSurnames : [PersonItem] ->  ()) {
        let request = NSMutableURLRequest(URL: searchUrl)
        request.HTTPMethod = "POST"
        request.cachePolicy = NSURLRequestCachePolicy.ReloadIgnoringCacheData
        
        let paramString = "actionaig=find&nom="+str
        //request.HTTPBody = paramString.dataUsingEncoding(NSUTF8StringEncoding)
        request.HTTPBody = paramString.dataUsingEncoding(NSASCIIStringEncoding)
        
        
        let s = NSURLSession.sharedSession()
        let task = s.dataTaskWithRequest(request) {
            (let data, let response, let error) in
            guard let _:NSData = data, let _:NSURLResponse = response  where error == nil else {
                print("Error fetching page")
                return
            }
            /*if let httpResponse = response as? NSHTTPURLResponse {
             print(httpResponse.statusCode)
             }*/
            //self.setCookies(response!) //debut
            // let dataString = NSString(data: data!, encoding: NSUTF8StringEncoding)
            let dataString = NSString(data: data!, encoding: NSASCIIStringEncoding)
            //print(dataString)
            completionSurnames(self.parseAgilResults(String(dataString)))
        }
        task.resume()
    }
    
    func searchIGG(str : String, completionIGG : PersonItem ->  ()) {
        let request = NSMutableURLRequest(URL: searchUrl)
        request.HTTPMethod = "POST"
        request.cachePolicy = NSURLRequestCachePolicy.ReloadIgnoringCacheData
        
        let paramString = "actionaig=find&igg="+str
        //request.HTTPBody = paramString.dataUsingEncoding(NSUTF8StringEncoding)
        request.HTTPBody = paramString.dataUsingEncoding(NSASCIIStringEncoding)
        
        
        let s = NSURLSession.sharedSession()
        let task = s.dataTaskWithRequest(request) {
            (let data, let response, let error) in
            guard let _:NSData = data, let _:NSURLResponse = response  where error == nil else {
                print("Error fetching page")
                return
            }
            let dataString = NSString(data: data!, encoding: NSASCIIStringEncoding)
            
            if let doc = Kanna.HTML(html: String(dataString), encoding: NSUTF8StringEncoding) {
                var currentSurname = ""
                var currentName = ""
                var currentIGG=""
                var currentEntity = [String]()
                
                var currentOffice=""
                var currentEmail=""
                
                var person: PersonItem
                
                // Case one result
                for node in doc.xpath("//td[contains(@class,'fichetext2')]") {
                    let strnode = self.cleanAgilEntry(node.text!)
                    let sA = strnode.characters.split{$0 == "\r"}.map(String.init)
                    let sName = sA[0].characters.split{$0 == " "}.map(String.init)
                    for s in sName {
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
                    
                    for s in sA {
                        if (s.rangeOfString("IGG : ") != nil) {
                            currentIGG = s.stringByReplacingOccurrencesOfString("IGG : ", withString: "")
                        } else if (s.rangeOfString("Entité : ") != nil) {
                            currentEntity = s.stringByReplacingOccurrencesOfString("Entité : ", withString: "").characters.split{$0 == "/"}.map(String.init)
                        } else if (s.rangeOfString("Bureau : ") != nil) {
                            currentOffice = s.stringByReplacingOccurrencesOfString("Bureau : ", withString: "")
                            currentOffice = currentOffice.stringByReplacingOccurrencesOfString(" ", withString: "")
                        } else if (s.rangeOfString("Email : ") != nil) {
                            currentEmail = s.stringByReplacingOccurrencesOfString("Email : ", withString: "")
                            currentEmail = currentEmail.stringByReplacingOccurrencesOfString(" ", withString: "")
                            
                        }
                    }
                    
                    
                    if (!currentIGG.isEmpty && !currentName.isEmpty && !currentSurname.isEmpty) {
                        person = PersonItem(surname: currentSurname, name: currentName, igg: currentIGG, entity: currentEntity)
                        if (!currentOffice.isEmpty) {
                            person.office = currentOffice
                        }
                        if (!currentEmail.isEmpty) {
                            person.email = currentEmail
                        }
                        completionIGG(person)
                    }
                    
                }
                
            }
            
        }
        task.resume()
    }
    
    func parseAgilResults(result : String) -> [PersonItem] {
        var personsArray = [PersonItem]()
        
        if let doc = Kanna.HTML(html: result, encoding: NSUTF8StringEncoding) {
            
            var currentSurname = ""
            var currentName = ""
            var currentIGG=""
            var currentEntity = [String]()
            
            var person: PersonItem
            
            for node in doc.xpath("//div[contains(@class,'noResult')] | //div/div[contains(@class,'messages')]") {
                print(node.content)
            }
            
            // Case several results
            for node in doc.xpath("//div/div/div/div[contains(@class,'personfield')] | //div/div/div/div/a[contains(@onclick,'personneSheet')]") {
                
                // New people
                if (node.className == "personfield1") {
                    currentSurname = ""
                    currentName = ""
                    currentIGG=""
                    currentEntity = [String]()
                }
                
                if (node["onclick"] != nil) {
                    let strnode = node["onclick"]
                    let range = strnode!.startIndex.advancedBy(15) ..< strnode!.startIndex.advancedBy(23)
                    currentIGG = strnode!.substringWithRange(range)
                    //print("[IGG]"+currentIGG)
                } else {
                    let strnode = cleanAgilEntry(node.text!)
                    if (!strnode.isEmpty) {
                        if (node.className == "personfield1") { // Name broker
                            //print("Break "+strnode)
                            let sA = strnode.characters.split{$0 == " "}.map(String.init)
                            for s in sA {
                                if (checkifLowerCaseIncluded(s)) {
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
                        } else if (node.className == "personfield5") { // Entity
                            currentEntity = strnode.characters.split{$0 == "/"}.map(String.init)
                            // Save person
                            if (personsArray.filter{$0.igg == currentIGG}.count == 0 && !currentIGG.isEmpty && !currentName.isEmpty && !currentSurname.isEmpty) {
                                person = PersonItem(surname: currentSurname, name: currentName, igg: currentIGG, entity: currentEntity)
                                person.computeRank(owner!.entity)
                                personsArray += [person]
                            }
                            /*} else {
                             print("["+node.className!+"]"+strnode)*/
                        }
                        
                    }
                }
                
            }
            
            // Case one result
            for node in doc.xpath("//td[contains(@class,'fichetext2')]") {
                let strnode = cleanAgilEntry(node.text!)
                let sA = strnode.characters.split{$0 == "\r"}.map(String.init)
                let sName = sA[0].characters.split{$0 == " "}.map(String.init)
                for s in sName {
                    if (checkifLowerCaseIncluded(s)) {
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
                currentIGG = sA[1].stringByReplacingOccurrencesOfString("IGG : ", withString: "")
                currentEntity = sA[79].stringByReplacingOccurrencesOfString("Entité : ", withString: "").characters.split{$0 == "/"}.map(String.init)
                if (personsArray.filter{$0.igg == currentIGG}.count == 0 && !currentIGG.isEmpty && !currentName.isEmpty && !currentSurname.isEmpty) {
                    person = PersonItem(surname: currentSurname, name: currentName, igg: currentIGG, entity: currentEntity)
                    return [person]
                }
            }
            
        }
        return personsArray
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
        
        func setCookies(response:NSURLResponse) {
            let cookies = NSHTTPCookieStorage.sharedHTTPCookieStorage().cookiesForURL(response.URL!)
            print(cookies)
        }
    }
    
}