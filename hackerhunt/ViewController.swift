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
    
    @IBOutlet weak var label: UILabel!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        label.text = "starting"
        
        // Initiate Beacon Manager
        beaconManager = KTKBeaconManager(delegate: self)
        
        switch KTKBeaconManager.locationAuthorizationStatus() {
            case .notDetermined:
                label.text = "authorising?"
                beaconManager.requestLocationAlwaysAuthorization()
                break
            case .denied, .restricted, .authorizedWhenInUse:
                label.text = "started"
                break
            case .authorizedAlways:
                label.text = "authorised"
                break
        }
        
        // Region
        let proximityUUID = NSUUID(uuidString: "f7826da6-4fa2-4e98-8024-bc5b71e0893e")
        let region = KTKBeaconRegion(proximityUUID: proximityUUID! as UUID, identifier: "default-region")
        
        // Start Monitoring and Ranging
        beaconManager.startMonitoring(for: region)
        beaconManager.startRangingBeacons(in: region)
    }
    
}

extension ViewController: KTKBeaconManagerDelegate {
    
    func beaconManager(_ manager: KTKBeaconManager, didRangeBeacons beacons: [CLBeacon], in region: KTKBeaconRegion) {
        print("Did ranged \"\(beacons.count)\" beacons")
        label.text = "Did ranged \"\(beacons.count)\" beacons"
    }
    
    func beaconManager(_ manager: KTKBeaconManager, didStartMonitoringFor region: KTKBeaconRegion) {
        // Do something when monitoring for a particular
        // region is successfully initiated
        print("Started monitoring region \"\(region)\"")
        label.text = "Started monitoring region \"\(region)\""
    }
    
    func beaconManager(_ manager: KTKBeaconManager, monitoringDidFailFor region: KTKBeaconRegion?, withError error: NSError?) {
        // Handle monitoring failing to start for your region
        print("Failed to monitor region \"\(String(describing: region))\"")
        label.text = "Failed to monitor region \"\(String(describing: region))\""
    }
    
    func beaconManager(_ manager: KTKBeaconManager, didEnter region: KTKBeaconRegion) {
        // Decide what to do when a user enters a range of your region; usually used
        // for triggering a local notification and/or starting a beacon ranging
        print("Entered region \"\(region)\"")
        label.text = "Entered region \"\(region)\""
    }
    
    func beaconManager(_ manager: KTKBeaconManager, didExitRegion region: KTKBeaconRegion) {
        // Decide what to do when a user exits a range of your region; usually used
        // for triggering a local notification and stoping a beacon ranging
        print("Exited region \"\(region)\"")
        label.text = "Exited region \"\(region)\""
    }
    
}
