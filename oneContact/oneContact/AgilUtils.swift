//
//  AgilUtils.swift
//  oneContact
//
//  Created by iero on 17/07/2016.
//  Copyright © 2016 Total. All rights reserved.
//

import Foundation
import Kanna

class AgilUtils {
    func parseAgilResults(result : String) -> [PersonItem] {
        var personsArray = [PersonItem]()
        
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
                        personsArray += [person]
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
