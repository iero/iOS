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
    
    let phoneOffice: String
    let phoneRIG: String
    let phoneMobile: String
    
    let countryID: String
    let site: String
    
    var entity = [String]()
    
    init(surname: String, name: String, igg: String, phoneRig : String, phoneOffice : String, phoneMobile : String, entity : [String], countryID :String, site : String) {
        self.name = name
        self.surname = surname
        self.igg = igg
        self.phoneOffice=phoneOffice
        self.phoneRIG=phoneRig
        self.phoneMobile=phoneMobile
        self.entity = entity
        self.countryID = countryID
        self.site = site
        
        /*print(self.igg + " ["+self.name+"] ["+self.surname+"] added")
        print("  Entity : "+self.getEntityName())
        print("  Location : ["+self.countryID+"] ["+self.site+"]")
        print("  Phone : ["+self.phoneRIG+"] ["+self.phoneOffice+"] ["+self.phoneMobile+"]")*/
    }

    init(surname: String, name: String, igg: String, phoneRig : String, phoneOffice : String, phoneMobile : String, entity : String, countryID :String, site : String) {
        self.name = name
        self.surname = surname
        self.igg = igg
        self.phoneOffice=phoneOffice
        self.phoneRIG=phoneRig
        self.phoneMobile=phoneMobile
        self.entity = entity.characters.split{$0 == "/"}.map(String.init)
        self.countryID = countryID
        self.site = site
        
        print(self.igg + " ["+self.name+"] ["+self.surname+"] added")
         print("  Entity : "+self.getEntityName())
         print("  Location : ["+self.countryID+"] ["+self.site+"]")
         print("  Phone : ["+self.phoneRIG+"] ["+self.phoneOffice+"] ["+self.phoneMobile+"]")
    }
    
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
    
    
}
