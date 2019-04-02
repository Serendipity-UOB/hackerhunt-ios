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
    var manager: CBCentralManager!
    var bluetoothTimer = Timer()
    
    init(withState gameState: GameState) {
        super.init()
        self.beaconManager = KTKBeaconManager(delegate: self)
        self.gameState = gameState
        let opts = [CBCentralManagerOptionShowPowerAlertKey: true]
        self.manager = CBCentralManager(delegate: self, queue: nil, options: opts)
        
    }
    
    func isOn() -> Bool {
        return self.manager.state == .poweredOn || ServerUtils.testing // true if either in testing mode or is actually on
    }
    
    func requestBluetoothOn() {
        let alertController = UIAlertController(title: "hackerhunt", message: "Please enable Bluetooth", preferredStyle: .alert)
        
        let action1 = UIAlertAction(title: "OK", style: .default) { (action:UIAlertAction) in
            self.bluetoothTimer.invalidate()
            self.bluetoothTimer = Timer.scheduledTimer(timeInterval: 3, target: self, selector: #selector(self.checkBluetooth), userInfo: nil, repeats: true)
        }
        alertController.addAction(action1)
        
        if var topController = UIApplication.shared.keyWindow?.rootViewController {
            while let presentedViewController = topController.presentedViewController {
                topController = presentedViewController
            }
            
            // topController should now be your topmost view controller
            topController.present(alertController, animated: true, completion: nil)
        }
        
    }
    
    @objc func checkBluetooth() {
        if (isOn()) {
            bluetoothTimer.invalidate()
        }
        else {
            requestBluetoothOn()
        }
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
            text += "\t\(beacon.major) \(beacon.minor): \(beacon.rssi), \(proximityFrom(enum: beacon.proximity))\n"
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
        let sortedBeacons = beacons.sorted(by: { $0.rssi > $1.rssi })
//        print(stringFrom(beacons: sortedBeacons))
        gameState.nearbyBeacons = sortedBeacons
    }

    
    func beaconManager(_ manager: KTKBeaconManager, didEnter region: KTKBeaconRegion) {
        print("Entered beacon range: \(region.identifier)\n")
    }
    
    func beaconManager(_ manager: KTKBeaconManager, didExitRegion region: KTKBeaconRegion) {
        print("Exited beacon range: \(region.identifier)\n")
    }
    
    func beaconManager(_ manager: KTKBeaconManager, didStartMonitoringFor region: KTKBeaconRegion) {
        print("Started monitoring region \"\(region.identifier)\"\n")
    }
    
    func beaconManager(_ manager: KTKBeaconManager, monitoringDidFailFor region: KTKBeaconRegion?, withError error: Error?) {
        print("Failed to monitor region \"\(String(describing: region?.identifier))\"\n")
    }
}

extension BeaconListener: CBCentralManagerDelegate {
    func centralManagerDidUpdateState(_ central: CBCentralManager) {
        if (central.state == .poweredOff && ServerUtils.testing == false) {
            requestBluetoothOn()
            
        }
    }
    
    
}
