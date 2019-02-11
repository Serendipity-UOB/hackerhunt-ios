//
//  TerminalViewController.swift
//  hackerhunt
//
//  Created by Louis Heath on 23/01/2019.
//  Copyright © 2019 Louis Heath. All rights reserved.
//

import UIKit

class TerminalViewController: UIViewController {
    
    @IBOutlet weak var terminalSubView: UIView!
    @IBOutlet weak var textView: UITextView!
    @IBOutlet weak var tapToCloseLbl: UITextView!
    
    var message: String = "default string"
    var homeBeacon = "A"
    var isShowing = false
    var tapToClose: Bool = true
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        terminalSubView.isUserInteractionEnabled = false
        textView.isUserInteractionEnabled = false
        tapToCloseLbl.isUserInteractionEnabled = false
        
        tapToCloseLbl.alpha = (tapToClose) ? 1 : 0
        textView.text = self.message
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        tapToCloseLbl.alpha = (tapToClose) ? 1 : 0
        textView.text = self.message
    }
    
    @IBAction func tapToClose(_ sender: UITapGestureRecognizer) {
        if (tapToClose) {
            DispatchQueue.main.async {
                self.removeAnimate()
            }
        }
    }
    
    func setTapToClose(_ tapToClose: Bool) {
        self.tapToClose = tapToClose
        if let tapToCloseLbl = tapToCloseLbl {
            tapToCloseLbl.alpha = (tapToClose) ? 1 : 0
        }
    }
    
    func setHomeBeacon(homeBeaconName: String) {
        self.homeBeacon = homeBeaconName
    }
    
    /* preset messages */
    
    func setMessage(message: String, tapToClose: Bool) {
        self.setTapToClose(tapToClose)
        self.message = message
    }
    
    func setMessage(gameStart: Any, tapToClose: Bool = false) {
        self.setTapToClose(tapToClose)
        self.message = "Incoming message...\n\nGo to beacon \"\(homeBeacon)\" to receive your first target!\n\n- Anon"
    }
    
    func setMessage(requestNewTarget: Any) {
        self.setTapToClose(false)
        self.message = "Too slow!\n\nSomeone took down your target\n\nGo back to \(homeBeacon) for a new one"
    }
    
    func setMessage(gameOver: Any) {
        self.setTapToClose(true)
        self.message = "Incoming message...\n\nGood work! Return your equipment to the stand to collect your reward.\n\n- Anon"
    }
    
    func setMessage(takenDown: Any) {
        self.setTapToClose(false)
        self.message = "SECURITY_FAILURE\n\nYour identity has been compromised. \n\nLose 50% of intel\n\nReturn to Beacon \"\(homeBeacon)\" to heal"
    }
    
    /* animations */
    
    func showAnimate() {
        self.view.transform = CGAffineTransform(scaleX: 1.3, y: 1.3)
        self.view.alpha = 0.0;
        UIView.animate(withDuration: 0.25, animations: {
            self.view.alpha = 1.0
            self.view.transform = CGAffineTransform(scaleX: 1.0, y: 1.0)
        });
    }
    
    func removeAnimate() {
        UIView.animate(withDuration: 0.25, animations: {
            self.view.transform = CGAffineTransform(scaleX: 1.3, y: 1.3)
            self.view.alpha = 0.0;
        }, completion:{(finished : Bool)  in
            if (finished)
            {
                self.view.removeFromSuperview()
            }
        });
    }
}
