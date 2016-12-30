//
//  WindowController.swift
//  BeaconMap
//
//  Created by Dalton Cherry on 12/23/16.
//  Copyright © 2016 vluxe. All rights reserved.
//

import Cocoa

class WindowController: NSWindowController {
    override func windowDidLoad() {
        super.windowDidLoad()
        window!.titleVisibility = .hidden
    }
    
    @IBAction func didTapInsert(btn: NSButton) {
        print("did tap insert!")
        guard let vc = contentViewController as? ViewController else {return}
        vc.didInsert()
    }
}
