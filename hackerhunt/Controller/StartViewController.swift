//
//  StartViewController.swift
//  hackerhunt
//
//  Created by Louis Heath on 21/11/2018.
//  Copyright © 2018 Louis Heath. All rights reserved.
//

import UIKit
import KontaktSDK

class StartViewController: UIViewController {
  
    var beaconController: BeaconController!
    
    @IBOutlet weak var titleLogoGif: UIImageView!
    @IBOutlet weak var errorMessage: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        titleLogoGif.loadGif(name: "title_logo")
        
        if (!beaconController.isAuthorised()) {
            beaconController.requestAuthorisation()
        }
    }

    @IBAction func startPressed(_ sender: Any) {
        if (beaconController.isAuthorised()) {
            beaconController.startMonitoring()
            self.performSegue(withIdentifier:"transitionToRegister", sender:self);
        } else {
            beaconController.requestAuthorisation()
            self.errorMessage.text = "Please enable Bluetooth access"
        }
        
    }
}
