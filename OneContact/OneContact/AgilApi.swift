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
    let s = NSURLSession.sharedSession()
    
    init() {
        print("Initiate Agil connection")
        
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

    
/*    func searchSurnames(str : String, completionSurnames : (result: String) ->  () ) {
        let request = NSMutableURLRequest(URL: searchUrl)
        request.HTTPMethod = "POST"
        //request.cachePolicy = NSURLRequestCachePolicy.ReloadIgnoringCacheData
        
        let paramString = "actionaig=find&nom="+str
        //request.HTTPBody = paramString.dataUsingEncoding(NSUTF8StringEncoding)
        request.HTTPBody = paramString.dataUsingEncoding(NSASCIIStringEncoding)
        
        //let s = NSURLSession.sharedSession()
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
            completionSurnames(result: String(dataString))
        }
        task.resume()
    }*/
    
    
    func searchNames(str : String, completionNames : (result: String) ->  () ) {
        let request = NSMutableURLRequest(URL: searchUrl)
        request.HTTPMethod = "POST"
        //request.cachePolicy = NSURLRequestCachePolicy.ReloadIgnoringCacheData
        
        let paramString = "actionaig=find&prenom="+str
        //request.HTTPBody = paramString.dataUsingEncoding(NSUTF8StringEncoding)
        request.HTTPBody = paramString.dataUsingEncoding(NSASCIIStringEncoding)

        
        //let s = NSURLSession.sharedSession()
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
            completionNames(result: String(dataString))
        }
        task.resume()
    }
    
    func searchIGG(igg : String, completionNames : (result: String) ->  () ) {
        let request = NSMutableURLRequest(URL: searchUrl)
        request.HTTPMethod = "POST"
        //request.cachePolicy = NSURLRequestCachePolicy.ReloadIgnoringCacheData
        
        let paramString = "actionaig=toPersonneSheet&id="+igg+"&hasSecondarySite=false"
        request.HTTPBody = paramString.dataUsingEncoding(NSASCIIStringEncoding)
        
        //let s = NSURLSession.sharedSession()
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
            print(dataString)
            completionNames(result: String(dataString))
        }
        task.resume()
    }
    
      
    
}