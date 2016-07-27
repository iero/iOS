//
//  PlistManager.swift
//  oneContact
//
//  Created by iero on 25/07/2016.
//  Copyright © 2016 Total. All rights reserved.
//

import Foundation

let plistFileName:String = "Employees"

struct PlistM {
    
    enum PlistError: ErrorType {
        case FileNotWritten
        case FileDoesNotExist
    }
    
    let name:String
    
    var sourcePath:String? {
        guard let path = NSBundle.mainBundle().pathForResource(name, ofType: "plist") else { return .None }
        return path
    }
    
    var destPath:String? {
        guard sourcePath != .None else { return .None }
        let dir = NSSearchPathForDirectoriesInDomains(.DocumentDirectory, .UserDomainMask, true)[0]
        return (dir as NSString).stringByAppendingPathComponent("\(name).plist")
    }
    
    init?(name:String) {
        
        self.name = name
        
        let fileManager = NSFileManager.defaultManager()
        
        guard let source = sourcePath else { return nil }
        guard let destination = destPath else { return nil }
        guard fileManager.fileExistsAtPath(source) else { return nil }
        
        if !fileManager.fileExistsAtPath(destination) {
            
            do {
                try fileManager.copyItemAtPath(source, toPath: destination)
            } catch let error as NSError {
                print("[PlistManager] Unable to copy file. ERROR: \(error.localizedDescription)")
                return nil
            }
        }
    }
    
    func getValuesInPlistFile() -> NSDictionary?{
        let fileManager = NSFileManager.defaultManager()
        if fileManager.fileExistsAtPath(destPath!) {
            guard let dict = NSDictionary(contentsOfFile: destPath!) else { return .None }
            return dict
        } else {
            return .None
        }
    }
    
    func getMutablePlistFile() -> NSMutableDictionary?{
        let fileManager = NSFileManager.defaultManager()
        if fileManager.fileExistsAtPath(destPath!) {
            guard let dict = NSMutableDictionary(contentsOfFile: destPath!) else { return .None }
            return dict
        } else {
            return .None
        }
    }
    
    func addValuesToPlistFile(dictionary:NSDictionary) throws {
        let fileManager = NSFileManager.defaultManager()
        if fileManager.fileExistsAtPath(destPath!) {
            if !dictionary.writeToFile(destPath!, atomically: false) {
                print("[PlistManager] File not written successfully")
                throw PlistError.FileNotWritten
            }
        } else {
            throw PlistError.FileDoesNotExist
        }
    }
    
}

class PlistManager {
    static let sharedInstance = PlistManager()
    private init() {} //This prevents others from using the default '()' initializer for this class.
    
    func startPlistManager() {
        if let _ = PlistM(name: plistFileName) {
            print("[PlistManager] PlistManager started")
        }
    }
    
    func addNewItemWithKey(key:String, value:AnyObject) {
        print("Add user "+key)
        //print("[PlistManager] Starting to add item for key '\(key) with value '\(value)' . . .")
        if !keyAlreadyExists(key) {
            if let plist = PlistM(name: plistFileName) {
                
                let dict = plist.getMutablePlistFile()!
                dict[key] = value
                
                do {
                    try plist.addValuesToPlistFile(dict)
                } catch {
                    print(error)
                }
                //print("[PlistManager] An Action has been performed. You can check if it went ok by taking a look at the current content of the plist file: ")
                //print("[PlistManager] \(plist.getValuesInPlistFile())")
            } else {
                print("[PlistManager] Unable to get Plist")
            }
        } /*else {
         print("[PlistManager] Item for key '\(key)' already exists. Not saving Item. Not overwriting value.")
         }*/
        
        
    }
    
    func removeItemForKey(key:String) {
        print("Remove user "+key)
        //print("[PlistManager] Starting to remove item for key '\(key) . . .")
        if keyAlreadyExists(key) {
            if let plist = PlistM(name: plistFileName) {
                
                let dict = plist.getMutablePlistFile()!
                dict.removeObjectForKey(key)
                
                do {
                    try plist.addValuesToPlistFile(dict)
                } catch {
                    print(error)
                }
                //print("[PlistManager] An Action has been performed. You can check if it went ok by taking a look at the current content of the plist file: ")
                //print("[PlistManager] \(plist.getValuesInPlistFile())")
            } else {
                print("[PlistManager] Unable to get Plist")
            }
        } else {
            print("[PlistManager] Item for key '\(key)' does not exists. Remove canceled.")
        }
        
    }
    
    func removeAllItemsFromPlist() {
        
        if let plist = PlistM(name: plistFileName) {
            
            let dict = plist.getMutablePlistFile()!
            
            let keys = Array(dict.allKeys)
            
            if keys.count != 0 {
                dict.removeAllObjects()
            } else {
                print("[PlistManager] Plist is already empty. Removal of all items canceled.")
            }
            
            do {
                try plist.addValuesToPlistFile(dict)
            } catch {
                print(error)
            }
            print("[PlistManager] An Action has been performed. You can check if it went ok by taking a look at the current content of the plist file: ")
            print("[PlistManager] \(plist.getValuesInPlistFile())")
        } else {
            print("[PlistManager] Unable to get Plist")
        }
    }
    
    func saveValue(value:AnyObject, forKey:String) {
        
        if let plist = PlistM(name: plistFileName) {
            
            let dict = plist.getMutablePlistFile()!
            
            if let dictValue = dict[forKey] {
                
                if value.dynamicType != dictValue.dynamicType {
                    print("[PlistManager] WARNING: You are saving a \(value.dynamicType) typed value into a \(dictValue.dynamicType) typed value. Best practice is to save Int values to Int fields, String values to String fields etc. (For example: '_NSContiguousString' to '__NSCFString' is ok too; they are both String types) If you believe that this mismatch in the types of the values is ok and will not break your code than disregard this message.")
                }
                
                dict[forKey] = value
                
            }
            
            do {
                try plist.addValuesToPlistFile(dict)
            } catch {
                print(error)
            }
            print("[PlistManager] An Action has been performed. You can check if it went ok by taking a look at the current content of the plist file: ")
            print("[PlistManager] \(plist.getValuesInPlistFile())")
        } else {
            print("[PlistManager] Unable to get Plist")
        }
    }
    
    func getAllKeys() -> Array<AnyObject>? {
        if let plist = PlistM(name: plistFileName) {
            
            let dict = plist.getMutablePlistFile()!
            print(String(dict.count)+" users recorded")
            return Array(dict.allKeys)
        }
        return .None
    }
    
    func loadUsers() -> [PersonItem] {
        var value = [PersonItem]()
        
        if let plist = PlistM(name: plistFileName) {
            
            let dict = plist.getMutablePlistFile()!
            let keys = Array(dict.allKeys)
            print(String(dict.count)+" users recorded")
            //print("[PlistManager] Keys are: \(keys)")
            
            if keys.count != 0 {
                for (_,element) in keys.enumerate() {
                    let key = String(element)
                    // Test duplicates
                    if (value.filter{$0.igg == key}.count == 0){
                        let dict = getValueForKey(key)
                        let surname = dict!["surname"] as! String
                        
                        let name = dict!["name"] as! String
                        let entity = dict!["entity"] as! String
                        let p  = PersonItem(surname: surname, name: name, igg: key, entity: entity)
                        value.append(p)
                    } else {
                        removeItemForKey(key)
                    }
                }
            } else {
                print("[PlistManager] The Plist is Empty!")
                return value
            }
            
        } else {
            print("[PlistManager] Unable to get Plist")
            return value
        }
        return value
    }
    
    func getValueForKey(key:String) -> AnyObject? {
        var value:AnyObject?
        
        if let plist = PlistM(name: plistFileName) {
            
            let dict = plist.getMutablePlistFile()!
            let keys = Array(dict.allKeys)
            //print("[PlistManager] Keys are: \(keys)")
            
            if keys.count != 0 {
                for (_,element) in keys.enumerate() {
                    //print("[PlistManager] Key Index - \(index) = \(element)")
                    if element as! String == key {
                        //print("[PlistManager] Found the Item that we were looking for key: [\(key)]")
                        //print(element.)
                        value = dict[key]!
                    } else {
                        //print("[PlistManager] This is Item with key '\(element)' and not the Item that we are looking for with key: \(key)")
                    }
                }
                
                if value != nil {
                    //print("[PlistManager] The Element that we were looking for exists: [\(key)]: \(value)")
                    return value!
                } else {
                    print("[PlistManager] WARNING: The Item for key '\(key)' does not exist! Please, check your spelling.")
                    return .None
                }
                
            } else {
                print("[PlistManager] No Plist Item Found when searching for item with key: \(key). The Plist is Empty!")
                return .None
            }
            
        } else {
            print("[PlistManager] Unable to get Plist")
            return .None
        }
    }
    
    func keyAlreadyExists(key:String) -> Bool {
        var keyExists = false
        if let plist = PlistM(name: plistFileName) {
            let dict = plist.getMutablePlistFile()!
            let keys = Array(dict.allKeys)
            print(String(keys.count)+" users registred")
            //print("[PlistManager] Keys are: \(keys)")
            
            if keys.count != 0 {
                
                for (_,element) in keys.enumerate() {
                    
                    //print("[PlistManager] Key Index - \(index) = \(element)")
                    if element as! String == key {
                        print("User "+key+" already exists")
                        //print("[PlistManager] Checked if item exists and found it for key: [\(key)]")
                        keyExists = true
                    } else {
                        //print("[PlistManager] This is Element with key '\(element)' and not the Element that we are looking for with Key: \(key)")
                    }
                }
                
            } else {
                //print("[PlistManager] No Plist Element Found with Key: \(key). The Plist is Empty!")
                keyExists =  false
            }
            
        } else {
            //print("[PlistManager] Unable to get Plist")
            keyExists = false
        }
        
        return keyExists
    }
    
}


