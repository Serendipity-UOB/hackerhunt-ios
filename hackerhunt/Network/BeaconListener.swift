//
//  BeaconListener.swift
//  hackerhunt
//
//  Created by Louis Heath on 21/01/2019.
//  Copyright © 2019 Louis Heath. All rights reserved.
//

import KontaktSDK

class BeaconListener: NSObject {
    
    var beaconManager: KTKBeaconManager!
    var gameState: GameState!
    
    init(withState gameState: GameState) {
        super.init()
        self.beaconManager = KTKBeaconManager(delegate: self)
        self.gameState = gameState
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
    
    func stringFrom(beacons: [CLBeacon]) -> String {
        var text = "beacons: \n"
        for beacon in beacons {
            text += "\t\(beacon.major): \(beacon.rssi), \(proximityFrom(enum: beacon.proximity))\n"
        }
        return text
    }
}

extension BeaconListener: KTKBeaconManagerDelegate {
    
    func proximityFrom(enum p: CLProximity) -> String {
        var proximities = ["unknown", "immediate", "near", "far"]
        return proximities[p.rawValue]
    }
    
    func beaconManager(_ manager: KTKBeaconManager, didRangeBeacons beacons: [CLBeacon], in region: KTKBeaconRegion) {
        // update game state
        let sortedBeacons = beacons.sorted(by: { $0.major.compare($1.major) == .orderedAscending })
        //print(stringFrom(beacons: sortedBeacons))
        gameState.nearbyBeacons = sortedBeacons
    }
    
    func beaconManager(_ manager: KTKBeaconManager, didEnter region: KTKBeaconRegion) {
        print("Entered beacon range: \(region)")
    }
    
    func beaconManager(_ manager: KTKBeaconManager, didExitRegion region: KTKBeaconRegion) {
        print("Exited beacon range: \(region)")
    }
    
    func beaconManager(_ manager: KTKBeaconManager, didStartMonitoringFor region: KTKBeaconRegion) {
        print("Started monitoring region \"\(region)\"")
    }
    
    func beaconManager(_ manager: KTKBeaconManager, monitoringDidFailFor region: KTKBeaconRegion?, withError error: Error?) {
        print("Failed to monitor region \"\(String(describing: region))\"")
    }
}
