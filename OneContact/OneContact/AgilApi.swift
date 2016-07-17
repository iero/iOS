//
//  AgilApi.swift
//  OneContact
//
//  Created by iero on 15/07/2016.
//  Copyright © 2016 Total. All rights reserved.
//

import Foundation

class AgilAPI {
    
    let baseUrl = NSURL(string: "http://agil.corp.local/agil/personne.view?actionaig=init")!
    let searchUrl = NSURL(string: "http://agil.corp.local/agil/personne.view")!
    let ieroUrl = NSURL(string: "http://www.iero.org/tmp/agil/original.html")!

    //var session : NSURLSession
    
    init() {
        print("Initiate Agil connection")
        let s = NSURLSession.sharedSession()
        
        let task = s.dataTaskWithURL(baseUrl) {
            (let data, let response, let error) in
            guard let _:NSData = data, let _:NSURLResponse = response  where error == nil else {
                print("Error fetching page")
                return
            }
            if let httpResponse = response as? NSHTTPURLResponse {
                print(httpResponse.statusCode)
            }
            //self.setCookies(response!)    //debug
            //let dataString = NSString(data: data!, encoding: NSUTF8StringEncoding)
            let dataString = NSString(data: data!, encoding: NSASCIIStringEncoding)
            //print(dataString)
        
            
        }
        task.resume()
    }
    
    func setCookies(response:NSURLResponse) {
        let cookies = NSHTTPCookieStorage.sharedHTTPCookieStorage().cookiesForURL(response.URL!)
        print(cookies)
    }
    
    func searchSurnames(str : String, completion : (result: String) ->  () ) {
        let request = NSMutableURLRequest(URL: searchUrl)
        request.HTTPMethod = "POST"
        //request.cachePolicy = NSURLRequestCachePolicy.ReloadIgnoringCacheData
        
        let paramString = "actionaig=find&nom="+str
        request.HTTPBody = paramString.dataUsingEncoding(NSUTF8StringEncoding)
        
        let s = NSURLSession.sharedSession()
        let task = s.dataTaskWithRequest(request) {
            (let data, let response, let error) in
            guard let _:NSData = data, let _:NSURLResponse = response  where error == nil else {
                print("Error fetching page")
                return
            }
            if let httpResponse = response as? NSHTTPURLResponse {
                print(httpResponse.statusCode)
            }
            //self.setCookies(response!) //debut
            // let dataString = NSString(data: data!, encoding: NSUTF8StringEncoding)
            let dataString = NSString(data: data!, encoding: NSASCIIStringEncoding)
            //print(dataString)
            completion(result: String(dataString))
        }
        task.resume()
    }

    
    
    func searchNames(str : String, completion : (result: String) ->  () ) {
        let request = NSMutableURLRequest(URL: searchUrl)
        request.HTTPMethod = "POST"
        //request.cachePolicy = NSURLRequestCachePolicy.ReloadIgnoringCacheData

        let paramString = "actionaig=find&prenom="+str
        request.HTTPBody = paramString.dataUsingEncoding(NSUTF8StringEncoding)
        
        let s = NSURLSession.sharedSession()
        let task = s.dataTaskWithRequest(request) {
            (let data, let response, let error) in
            guard let _:NSData = data, let _:NSURLResponse = response  where error == nil else {
                print("Error fetching page")
                return
            }
            if let httpResponse = response as? NSHTTPURLResponse {
                print(httpResponse.statusCode)
            }
            //self.setCookies(response!) //debut
            // let dataString = NSString(data: data!, encoding: NSUTF8StringEncoding)
            let dataString = NSString(data: data!, encoding: NSASCIIStringEncoding)
            //print(dataString)
            completion(result: String(dataString))
        }
        task.resume()
    }
    
}