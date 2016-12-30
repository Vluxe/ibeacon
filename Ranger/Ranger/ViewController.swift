//
//  ViewController.swift
//  Ranger
//
//  Created by Austin Cherry on 12/23/16.
//  Copyright © 2016 Austin Cherry. All rights reserved.
//

import UIKit
import CoreLocation

class ViewController: UIViewController, CLLocationManagerDelegate {
    let locationManager = CLLocationManager()
    let uuids = [UUID(uuidString: "E2C56DB5-DFFB-48D2-B060-D0F5A71096E0"), UUID(uuidString: "5A4BCFCE-174E-4BAC-A814-092E77F6B7E5"), UUID(uuidString: "74278BDA-B644-4520-8F0C-720EAF059935")]
    var regions = [CLBeaconRegion]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
    
        locationManager.delegate = self
        locationManager.requestAlwaysAuthorization()
        //locationManager.startMonitoring(for: CLBeaconRegion(proximityUUID: UUID(), identifier: "vluxe.BLE"))
        
        for uuid in uuids {
            guard let uuid = uuid else {return}
            regions.append(CLBeaconRegion(proximityUUID: uuid, identifier: uuid.uuidString))
        }
        
        updateRegions()
    }
    
    func updateRegions() {
        for region in regions {
            locationManager.startRangingBeacons(in: region)
        }
    }
    
    // MARK: - CLLocationManagerDelegate
    
    func locationManager(_ manager: CLLocationManager, didRangeBeacons beacons: [CLBeacon], in region: CLBeaconRegion) {
        if beacons.count > 0 {
            var data = [BeaconData]()
            for beacon in beacons {
                if beacon.accuracy > 0 {
                    data.append(BeaconData(uuid: region.proximityUUID.uuidString, distance: Float(beacon.accuracy)))
                }
            }
            if data.count > 0 {
                Service.shared.post(beacons: data)
            }
        }
    }
}

