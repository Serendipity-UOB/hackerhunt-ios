//
//  ViewController.swift
//  hackerhunt
//
//  Created by Louis Heath on 21/11/2018.
//  Copyright © 2018 Louis Heath. All rights reserved.
//

import UIKit
import KontaktSDK

class StartViewController: UIViewController {
  
    var beaconManager: KTKBeaconManager!
    
    @IBOutlet weak var titleLogoGif: UIImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        titleLogoGif.loadGif(name: "title_logo")
        
        configureKontakt()
    }
    
    func configureKontakt() {
        beaconManager = KTKBeaconManager(delegate: self)
        
        if (KTKBeaconManager.locationAuthorizationStatus() == .notDetermined) {
            beaconManager.requestLocationAlwaysAuthorization()
        }
        
        switch KTKBeaconManager.locationAuthorizationStatus() {
        case .notDetermined:
            print("not determined")
            break
        case .denied, .restricted:
            print("unauthorised")
            break
        case .authorizedWhenInUse, .authorizedAlways:
            print("authorised")
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

extension StartViewController: KTKBeaconManagerDelegate {
    
    func proximityFrom(enum p: CLProximity) -> String {
        var proximities = ["unknown", "immediate", "near", "far"]
        return proximities[p.rawValue]
    }
    
    func beaconNameFrom(major m: NSNumber) -> String {
        if (m.intValue > 5) {
            return "FAIL:\(m)"
        }
        var majorToName = [ "", "4VSu", "7Wuj", "gHm1", "", "20LC" ]
        return majorToName[m.intValue]
    }
    
    func beaconManager(_ manager: KTKBeaconManager, didRangeBeacons beacons: [CLBeacon], in region: KTKBeaconRegion) {
        // show a list of beacons and their RSSI
        let sorted = beacons.sorted(by: { $0.major.compare($1.major) == .orderedAscending })
        var text = ""
        for beacon in sorted {
            text += "beacon: \(beaconNameFrom(major: beacon.major)), rssi: \(beacon.rssi)\nprox: \(proximityFrom(enum: beacon.proximity))\n\n"
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
