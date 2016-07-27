//
//  ResearchItem.swift
//  oneContact
//
//  Created by iero on 18/07/2016.
//  Copyright © 2016 Total. All rights reserved.
//

import Foundation

struct ResearchItem {
    
    let value : String
    let date : NSDate
    let foundNames : Int
    let foundSurnames: Int
    
    init(value: String, date: NSDate, s:Int, n:Int) {
        self.value = value
        self.date = date
        self.foundSurnames = s
        self.foundNames=n
    }
    
}