//
//  DetailViewController.swift
//  oneContact
//
//  Created by iero on 17/07/2016.
//  Copyright © 2016 Total. All rights reserved.
//

import UIKit

class DetailViewController: UIViewController {
    
    @IBOutlet weak var personPicture: UIImageView!
    @IBOutlet weak var igg: UILabel!
    
    enum ErrorHandling:ErrorType
    {
        case NetworkError
    }
    
    var person: PersonItem? {
        didSet {
            configureView()
        }
    }
    
    func configureView() {
        if let p = self.person {
            if let igg = self.igg {
                title = p.getCompleteName()
                igg.text = p.igg
                let lowIgg = p.igg.lowercaseString
                load_image("http://agil.corp.local:80/agil/photoReader?path=/loc/giseh/"+lowIgg+".jpg")
                parseAgil(p.igg)
            }
        }
    }
    
    func parseAgil(igg: String) {
        print("Looking for details on "+igg)
        let agil = AgilAPI()
        let agilutils = AgilUtils()
        agil.searchIGG(igg) {
            (result: String) in agilutils.parseAgilResults(result)
            //self.tableView.reloadData()
            dispatch_async(dispatch_get_main_queue(), { () -> Void in
                //personsArray.sortInPlace({ $0.surname < $1.surname })
                //print(String(self.personsArray.count)+" persons after name search")
            })
        }
        
    }
    
    func load_image(urlString:String)
    {
        let imgURL: NSURL = NSURL(string: urlString)!
        let request: NSURLRequest = NSURLRequest(URL: imgURL)
        
        let session = NSURLSession.sharedSession()
        let task = session.dataTaskWithRequest(request){
            (data, response, error) -> Void in
            
            if (error == nil && data != nil)
            {
                func display_image()
                {
                    self.personPicture.image = UIImage(data: data!)
                }
                
                dispatch_async(dispatch_get_main_queue(), display_image)
            } else {
                print(error)
            }
            
        }
        
        task.resume()
    }

    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureView()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
}


