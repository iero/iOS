//
//  DetailViewController.swift
//  SearchbarTutorial
//
//  Created by Marco Aurelio Viana Almeida on 12/16/15.
//  Copyright © 2015 appscg.com. All rights reserved.
//

import UIKit

class DetailViewController: UIViewController {

    @IBOutlet weak var detailDescriptionLabel: UILabel!
    @IBOutlet weak var carImage: UIImageView!


    var carDetail: Car? {
        didSet {
            // Update the view.
            self.configureView()
        }
    }

    func configureView() {
        // Update the user interface for the detail item.
        if let detail = self.carDetail {
            if let label = self.detailDescriptionLabel {
                label.text = detail.model
                carImage.image = UIImage(named: detail.image)
            }
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        self.configureView()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

