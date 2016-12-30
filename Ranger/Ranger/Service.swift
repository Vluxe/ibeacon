//
//  Service.swift
//  Ranger
//
//  Created by Austin Cherry on 12/29/16.
//  Copyright © 2016 Austin Cherry. All rights reserved.
//

import UIKit
import JSONJoy
import SwiftHTTP

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

class Service {
    static let shared = Service()
    let operationQueue = OperationQueue()
    
    init() {
        operationQueue.maxConcurrentOperationCount = 3
    }
    
    func post(beacons: [BeaconData]) {
        var beaconPost = [Dictionary<String, Any>]()
        for beacon in beacons {
            beaconPost.append(beacon.serializeToJSON())
        }
        
        do {
            let opt = try HTTP.POST("http://192.168.2.237:6000/ibeacon", parameters: ["phone_id": UIDevice.current.name, "beacon_data": beaconPost], requestSerializer: JSONParameterSerializer())
            opt.onFinish = { response in
                if let error = response.error {
                    print("got an error: \(error)")
                    return
                }
                print(response.text ?? "")
            }
            operationQueue.addOperation(opt)
        } catch let error {
            print("got an error: \(error)")
        }
    }
}
