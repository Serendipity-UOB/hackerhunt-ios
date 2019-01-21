//
//  BeaconController.swift
//  hackerhunt
//
//  Created by Louis Heath on 21/01/2019.
//  Copyright © 2019 Louis Heath. All rights reserved.
//

import KontaktSDK

class BeaconController: NSObject {
    
    var beaconManager: KTKBeaconManager!
    
    override init() {
        super.init()
        beaconManager = KTKBeaconManager(delegate: self)
    }
    
    func isAuthorised() -> Bool {
        let status = KTKBeaconManager.locationAuthorizationStatus()
        if (status == .authorizedWhenInUse || status == .authorizedAlways) {
            return true
        }
        return false
    }
    
    func requestAuthorisation() {
        beaconManager.requestLocationAlwaysAuthorization()
    }
    
    func startMonitoring() {
        let proximityUUID = NSUUID(uuidString: "f7826da6-4fa2-4e98-8024-bc5b71e0893e")
        let region = KTKBeaconRegion(proximityUUID: proximityUUID! as UUID, identifier: "mvb")
        
        beaconManager.startMonitoring(for: region)
        beaconManager.startRangingBeacons(in: region)
    }
}

extension BeaconController: KTKBeaconManagerDelegate {
    
    func proximityFrom(enum p: CLProximity) -> String {
        var proximities = ["unknown", "immediate", "near", "far"]
        return proximities[p.rawValue]
    }
    
    func beaconManager(_ manager: KTKBeaconManager, didRangeBeacons beacons: [CLBeacon], in region: KTKBeaconRegion) {
        // show a list of beacons and their RSSI
        let sorted = beacons.sorted(by: { $0.major.compare($1.major) == .orderedAscending })
        var text = "beacons: "
        for beacon in sorted {
            text += "beacon: \(beacon.major), rssi: \(beacon.rssi)\nprox: \(proximityFrom(enum: beacon.proximity))\n\n"
        }
        print(text)
    }
    
    func beaconManager(_ manager: KTKBeaconManager, didEnter region: KTKBeaconRegion) {
        // Entered range of region
        //   Player is within MVB
        print("Entered beacon range: \(region)")
    }
    
    func beaconManager(_ manager: KTKBeaconManager, didExitRegion region: KTKBeaconRegion) {
        // Entered range of region
        //   Player has left MVB, notify player and server?
        print("Exited beacon range: \(region)")
    }
    
    /*
     These don't seem to get hit. We also don't really need them but leave in for debug
     */
    
    func beaconManager(_ manager: KTKBeaconManager, didStartMonitoringFor region: KTKBeaconRegion) {
        print("Started monitoring region \"\(region)\"")
    }
    
    func beaconManager(_ manager: KTKBeaconManager, monitoringDidFailFor region: KTKBeaconRegion?, withError error: Error?) {
        print("Failed to monitor region \"\(String(describing: region))\"")
    }
}
