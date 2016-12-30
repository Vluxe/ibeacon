//
//  ViewController.swift
//  BeaconMap
//
//  Created by Dalton Cherry on 12/23/16.
//  Copyright © 2016 vluxe. All rights reserved.
//

import Cocoa
import Starscream
import JSONJoy

struct BeaconData: JSONJoy {
    let uuid: String
    let distance: Float
    
    init(uuid: String, distance: Float) {
        self.uuid = uuid
        self.distance = distance
    }
    
    init(_ decoder: JSONDecoder) throws {
        uuid = try decoder["uuid"].get()
        distance = try decoder["distance"].get()
    }
    
    func serializeToJSON() -> Dictionary<String, Any> {
        return ["uuid": uuid, "distance": distance]
    }
}

struct Model: JSONJoy {
    let iphoneId: String
    let beaconData: [BeaconData]
    
    init(iphoneId: String, beaconData: [BeaconData]) {
        self.iphoneId = iphoneId
        self.beaconData = beaconData
    }
    
    init(_ decoder: JSONDecoder) throws {
        iphoneId = try decoder["phone_id"].get()
        beaconData = try decoder["beacon_data"].get()
    }
    
    func serializeToJSON() -> Dictionary<String, Any> {
        var beacons = [Dictionary<String, Any>]()
        for beacon in beaconData {
            beacons.append(beacon.serializeToJSON())
        }
        return ["phone_id": iphoneId, "beaconData": beacons]
    }
}


class ViewController: NSViewController {
    var beaconView: BeaconView {
        return view as! BeaconView
    }
    var beacon1: CGFloat = 0
    var beacon2: CGFloat = 0
    var beacon3: CGFloat = 0
    let beacon1Name = "E2C56DB5-DFFB-48D2-B060-D0F5A71096E0"
    let beacon2Name = "5A4BCFCE-174E-4BAC-A814-092E77F6B7E5"
    let beacon3Name = "74278BDA-B644-4520-8F0C-720EAF059935"
    
    let socket = WebSocket(url: URL(string: "ws://192.168.2.237:6000/ibeacon")!)
    override func viewDidLoad() {
        super.viewDidLoad()
        socket.onConnect = {
            Swift.print("connected!")
        }
        socket.onDisconnect = { (error) in
            Swift.print("disconnected: \(error?.localizedDescription)")
        }
        socket.onText = {[unowned self] (text) in
            self.parse(text: text)
            Swift.print("got some text: \(text)")
        }
        socket.connect()
    }
    
    func parse(text: String) {
        do {
            let m = try Model(JSONDecoder(text))
            guard let first = m.beaconData.first else {return}
            if first.uuid == beacon1Name {
                beacon1 = CGFloat(first.distance)
            } else if first.uuid == beacon2Name {
                beacon2 = CGFloat(first.distance)
            } else if first.uuid == beacon3Name {
                beacon3 = CGFloat(first.distance)
            }
            if beacon1 > 0 && beacon2 > 0 && beacon3 > 0 {
                beaconView.updateUser(dist1: beacon1, dist2: beacon2, dist3: beacon3)
            }
        } catch let error {
            Swift.print("got an error: \(error)")
        }
    }

    override var representedObject: Any? {
        didSet {
        // Update the view, if already loaded.
        }
    }
    
    func didInsert() {
        //beaconView.addBeacon()
    }


}

