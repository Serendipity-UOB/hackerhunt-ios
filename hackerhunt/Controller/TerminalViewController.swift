//
//  TerminalViewController.swift
//  hackerhunt
//
//  Created by Louis Heath on 23/01/2019.
//  Copyright © 2019 Louis Heath. All rights reserved.
//

import UIKit

class TerminalViewController: UIViewController {
    
    @IBOutlet weak var textView: UITextView!
    
    var message: String = "default string"
    var tapToCloseEnabled = true
    var homeBeacon = "A"
    var isShowing = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        textView.text = self.message
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        textView.text = self.message
    }
    
    @IBAction func tapToClose(_ sender: UITapGestureRecognizer) {
        if (tapToCloseEnabled) {
            removeAnimate()
        }
    }
    
    /* preset messages */
    
    func setMessage(tapToClose: Bool, message: String) {
        self.tapToCloseEnabled = tapToClose
        self.message = message
    }
    
    func setMessage(gameStart: Any) {
        tapToCloseEnabled = false
        message = "Incoming message...\n\nGo to beacon \"\(homeBeacon)\" to receive your first target!\n\n- Anon"
    }
    
    func setMessage(requestNewTarget: Any) {
        tapToCloseEnabled = false
        message = "Too slow!\n\nSomeone took down your target\n\nGo back to Beacon \"\(homeBeacon)\" for a new one"
    }
    
    func setMessage(gameOver: Any) {
        tapToCloseEnabled = true
        message = "Incoming message...\n\nGood work! Return your equipment to the stand to collect your reward.\n\n- Anon"
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
