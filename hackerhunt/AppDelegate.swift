//
//  AppDelegate.swift
//  hackerhunt
//
//  Created by Louis Heath on 21/11/2018.
//  Copyright © 2018 Louis Heath. All rights reserved.
//

import UIKit
import KontaktSDK

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        
        // Set API Key
        Kontakt.setAPIKey("pNqcUiJPjCLoeibtwzmjKkZwoPBPGXYS")
        
        let gameState = GameState()
        let beaconListener = BeaconListener(withState: gameState)
        
        if let startViewController = window?.rootViewController as? StartViewController {
            startViewController.gameState = gameState
            startViewController.beaconListener = beaconListener
        }
        
        return true
    }
}
