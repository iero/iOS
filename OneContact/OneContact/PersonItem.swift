//
//  PersonItem.swift
//  oneContact
//
//  Created by iero on 17/07/2016.
//  Copyright © 2016 Total. All rights reserved.
//

import Foundation

struct PersonItem {
    let surname: String //Nom
    let name: String    //Prenom
    let igg: String
    var entity = [String]()

    // For detailed profile
    var office: String?
    var email: String?
    
    //var rank: Int? // 1 in same division, 2 in same entity..
    
    
    init(surname: String, name: String, igg: String, entity : [String]) {
        self.name = name
        self.surname = surname
        self.igg = igg
        self.entity = entity
}

    init(surname: String, name: String, igg: String, entity : String) {
        self.name = name
        self.surname = surname
        self.igg = igg
        setEntityName(entity)
        
        //print(self.igg + " ["+self.name+"] ["+self.surname+"] added")
        //print("  Entity : "+self.getEntityName())
    }
    
     /*func computeRank(ent : [String]) {
        var i=0
        var r=0
        for e in ent {
            if (self.entity.count >= i && e == self.entity[i]) {
                r += 1
                i += 1
            } else {
                rank = r
                return
            }
        }
        rank = r
        return
    }*/
    
    func getCompleteName() -> String {
        return name+" "+surname
    }

    func getNameForListing() -> String {
        return surname+" "+name
    }

    
    func getEntityName() -> String {
        var e = ""
        
        for s in self.entity {
            if (e.characters.count > 0) {
                e = e+"/"
            }
            e = e+s
        }
        return e
    }
    
    mutating func setEntityName(entity: String) {
        self.entity = entity.characters.split{$0 == "/"}.map(String.init)
    }
    
/*    func encodeWithCoder(aCoder: NSCoder!) {
        aCoder.encodeObject(igg, forKey:"igg")
        aCoder.encodeObject(surname, forKey:"surname")
        aCoder.encodeObject(name, forKey:"name")
        aCoder.encodeObject(getEntityName(), forKey:"entity")
    }
    
    init (coder aDecoder: NSCoder!) {
        self.igg = aDecoder.decodeObjectForKey("igg") as! String
        self.surname = aDecoder.decodeObjectForKey("surname") as! String
        self.name = aDecoder.decodeObjectForKey("name") as! String
        setEntityName(aDecoder.decodeObjectForKey("entity") as! String)
    }*/
}