//
//  ViewController.swift
//  hackerhunt
//
//  Created by Louis Heath on 21/11/2018.
//  Copyright © 2018 Louis Heath. All rights reserved.
//

import UIKit
import KontaktSDK

class ViewController: UIViewController {
  
    var beaconManager: KTKBeaconManager!
    
    @IBOutlet weak var infoLbl: UILabel!
    @IBOutlet weak var countLbl: UILabel!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        infoLbl.text = "starting"
        countLbl.text = ""
        
        // Initiate Beacon Manager
        beaconManager = KTKBeaconManager(delegate: self)
        
        if (KTKBeaconManager.locationAuthorizationStatus() == .notDetermined) {
            beaconManager.requestLocationAlwaysAuthorization()
        }
        
        switch KTKBeaconManager.locationAuthorizationStatus() {
        case .notDetermined:
            break
        case .denied, .restricted:
            infoLbl.text = "unauthorised"
            break
        case .authorizedWhenInUse, .authorizedAlways:
            infoLbl.text = ""
            break
        }
        
        // Region
        let proximityUUID = NSUUID(uuidString: "f7826da6-4fa2-4e98-8024-bc5b71e0893e")
        let region = KTKBeaconRegion(proximityUUID: proximityUUID! as UUID, identifier: "mvb")
        
        // Start Monitoring and Ranging
        beaconManager.startMonitoring(for: region)
        beaconManager.startRangingBeacons(in: region)
    }
    
}

extension ViewController: KTKBeaconManagerDelegate {
    
    func proximityFrom(enum p: CLProximity) -> String {
        var proximities = ["unknown", "immediate", "near", "far"]
        return proximities[p.rawValue]
    }
    
    func beaconNameFrom(major m: NSNumber) -> String {
        var majorToName = [ "", "4VSu", "7Wuj", "gHm1", "20LC" ]
        return majorToName[m.intValue]
    }
    
    func beaconManager(_ manager: KTKBeaconManager, didRangeBeacons beacons: [CLBeacon], in region: KTKBeaconRegion) {
        // show a list of beacons and their RSSI
        let sorted = beacons.sorted(by: { $0.major.compare($1.major) == .orderedAscending })
        var text = ""
        for beacon in sorted {
            text += "beacon: \(beaconNameFrom(major: beacon.major)), rssi: \(beacon.rssi)\nprox: \(proximityFrom(enum: beacon.proximity)), accuracy: \(Double(round(100*beacon.accuracy)/100))\n\n"
        }
        countLbl.text = text
    }
    
    func beaconManager(_ manager: KTKBeaconManager, didEnter region: KTKBeaconRegion) {
        // Entered range of region
        //   Player is within MVB
        print("Entered beacon range: \(region)")
        infoLbl.text = "Entered MVB"
    }
    
    func beaconManager(_ manager: KTKBeaconManager, didExitRegion region: KTKBeaconRegion) {
        // Entered range of region
        //   Player has left MVB, notify player and server?
        print("Exited beacon range: \(region)")
        infoLbl.text = "Not in MVB"
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
