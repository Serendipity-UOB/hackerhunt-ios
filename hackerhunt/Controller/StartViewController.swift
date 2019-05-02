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
  
    var runTutorial = false
    
    var beaconListener: BeaconListener!
    var gameState: GameState!
    
    @IBOutlet weak var titleLogoGif: UIImageView!
    @IBOutlet weak var errorMessage: UILabel!
    @IBOutlet weak var testingButton: UIButton!
    @IBOutlet weak var startButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //testingButton.setTitle((ServerUtils.testing) ? "testing on" : "testing off", for: .normal)

        titleLogoGif.loadGif(name: "title_screen")
        
        if (!beaconListener.isAuthorised()) {
            beaconListener.requestAuthorisation()
        }
    }

    /* Transition methods */
    
    @IBAction func startPressed(_ sender: Any) {
        if (beaconListener.isAuthorised() && beaconListener.isOn()) {
            beaconListener.startMonitoring()
            progressToGame()
        } else {
            if (!beaconListener.isAuthorised()) {
                beaconListener.requestAuthorisation()
            }
            else if (!beaconListener.isOn()) {
                beaconListener.requestBluetoothOn()
            }
        }
    }
    
    func progressToGame() {
        if (runTutorial) {
            self.performSegue(withIdentifier:"transitionToTutorial", sender:self);
        } else {
            self.performSegue(withIdentifier:"transitionToRegister", sender:self);
        }
    }
    
    @IBAction func testingModePressed(_ sender: Any) {
        ServerUtils.testing = !ServerUtils.testing
        testingButton.setTitle((ServerUtils.testing) ? "testing on" : "testing off", for: .normal)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let registerViewController = segue.destination as? RegisterViewController {
            registerViewController.gameState = gameState
        } else if let tutorialViewController = segue.destination as? TutorialViewController {
            tutorialViewController.gameState = gameState
            tutorialViewController.exitSegue = "tutorialToRegister"
        }
    }
}
