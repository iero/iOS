//
//  Debouncer.swift
//  oneContact
//
//  Created by iero on 19/07/2016.
//  Copyright © 2016 Total. All rights reserved.
//

import Foundation

class Debouncer: NSObject {
    var callback: (() -> ())
    var delay: Double
    weak var timer: NSTimer?
    
    init(delay: Double, callback: (() -> ())) {
        self.delay = delay
        self.callback = callback
    }
    
    func call() {
        timer?.invalidate()
        let nextTimer = NSTimer.scheduledTimerWithTimeInterval(delay, target: self, selector: #selector(Debouncer.fireNow), userInfo: nil, repeats: false)
        timer = nextTimer
    }
    
    func fireNow() {
        self.callback()
    }
}