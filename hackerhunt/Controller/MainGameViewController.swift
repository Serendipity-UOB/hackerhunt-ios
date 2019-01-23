//
//  MainGameViewController.swift
//  hackerhunt
//
//  Created by Louis Heath on 21/01/2019.
//  Copyright © 2019 Louis Heath. All rights reserved.
//

import UIKit

class MainGameViewController: UIViewController {
    
    var gameState: GameState!
    var terminalVC : TerminalViewController = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "terminalViewController") as! TerminalViewController
    
    var timer = Timer()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1, execute: {
            self.terminalVC.setMessage(homeBeacon: self.gameState.homeBeacon!)
            self.showTerminal()
        })
        
        startCheckingForHomeBeacon()
    }
    
    func startCheckingForHomeBeacon() {
        timer.invalidate()
        timer = Timer.scheduledTimer(timeInterval: 5, target: self, selector: #selector(MainGameViewController.checkForHomeBeacon), userInfo: nil, repeats: true)
    }
    
    @objc func checkForHomeBeacon() {
        if (self.gameState.getNearestBeacon() == "A") {
            DispatchQueue.main.asyncAfter(deadline: .now() + 5.0, execute: {
                self.hideTerminal()
            })
        }
    }
    
    func showTerminal() {
        self.addChild(terminalVC)
        self.view.addSubview(terminalVC.view)
        terminalVC.didMove(toParent: self)
        terminalVC.showAnimate()
    }
    
    func hideTerminal() {
        terminalVC.willMove(toParent: nil)
        terminalVC.removeFromParent()
        terminalVC.removeAnimate()
    }
}
