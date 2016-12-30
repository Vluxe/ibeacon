//
//  View.swift
//  BeaconMap
//
//  Created by Dalton Cherry on 12/23/16.
//  Copyright © 2016 vluxe. All rights reserved.
//

import AppKit

open class View: NSView {
    open override var wantsUpdateLayer: Bool { return true }
    public required init?(coder: NSCoder) {
        super.init(coder: coder)
        setup()
    }
    
    override init(frame frameRect: NSRect) {
        super.init(frame: frameRect)
        setup()
    }
    
    func setup() {
        wantsLayer = true
    }
    
    
}
