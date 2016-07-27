//
//  DetailViewController.swift
//  oneContact
//
//  Created by iero on 17/07/2016.
//  Copyright © 2016 Total. All rights reserved.
//

import UIKit

class DetailViewController: UIViewController  {
    
    @IBOutlet weak var personPicture: UIImageView!
    @IBOutlet weak var igg: UILabel!
    @IBOutlet weak var office: UILabel!
    @IBOutlet weak var email: UITextView!
    
    enum ErrorHandling:ErrorType
    {
        case NetworkError
    }
    
    var person: PersonItem? {
        didSet {
            configureView()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        personPicture.layer.borderWidth = 1
        personPicture.layer.masksToBounds = false
        personPicture.layer.borderColor = UIColor.blackColor().CGColor
        personPicture.layer.cornerRadius = personPicture.frame.height/2
        personPicture.clipsToBounds = true
        
        email.editable = false
        email.dataDetectorTypes = UIDataDetectorTypes.All
        
        configureView()
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
        agil.searchIGG(igg) {
            (completionIGG: PersonItem) in //agilutils.parseAgilResults(result)
            dispatch_async(dispatch_get_main_queue(), { () -> Void in
               print(completionIGG.getCompleteName())
                self.email.text = completionIGG.email!
                self.office.text = completionIGG.office
                self.email.attributedText = NSMutableAttributedString(string: "mailto:"+completionIGG.email!)
/*                let attributedString = NSMutableAttributedString(string: completionIGG.email!)
                attributedString.addAttribute(NSLinkAttributeName, value: "mailto:"+completionIGG.email!, range: NSRange(location: 19, length: 55))
                self.email.attributedText = attributedString*/

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
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
}


