//
//  TerminalViewController.swift
//  hackerhunt
//
//  Created by Louis Heath on 23/01/2019.
//  Copyright © 2019 Louis Heath. All rights reserved.
//

import UIKit

class TerminalViewController: UIViewController {
    
    @IBOutlet weak var alertBackgroundImage: UIImageView!
    @IBOutlet weak var alertTitleLabel: UILabel!
    @IBOutlet weak var missionDetails: UITextView!
    @IBOutlet var missionDetailsRatio: NSLayoutConstraint!
    @IBOutlet weak var tapLabel: UILabel!
    
    var message: String = "default string"
    var titleMessage: String = "default title"
    var homeBeacon = "A"
    var isShowing = false
    var tapToClose: Bool = true
    var backgroundImage: UIImage!
    var newMissionDetailsRatio: CGFloat = 1.0
    var titleColour: UIColor!
    
    var ratios: [String: CGFloat] = ["game_start":3.0, "exposed":1.5, "request_target":1.8, "expose_success":2.0]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        missionDetails.isUserInteractionEnabled = false
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
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
        self.newMissionDetailsRatio = ratios["game_start"]!
        self.titleColour = UIColor(red:0.00, green:0.79, blue:0.85, alpha:1.0)
        self.titleMessage = "GAME START"
        self.backgroundImage = UIImage(named: "neutral_full_pop_up")
        self.message = "Welcome, Agent. \nGo to game zone \(homeBeacon) for your first target."
    }
    
    func setMessage(requestNewTarget: Any) {
        self.newMissionDetailsRatio = ratios["request_target"]!
        self.titleColour = UIColor(red:0.00, green:0.79, blue:0.85, alpha:1.0)
        self.titleMessage = "TOO SLOW"
        self.backgroundImage = UIImage(named: "neutral_full_pop_up")
        self.message = "Your target was Exposed by another agent.\n\nReturn to \(homeBeacon) to be assigned a new target."
    }
    
    func setMessage(gameOver: Any) {
        self.setTapToClose(true)
        self.message = "Incoming message...\n\nGood work! Return your equipment to the stand to collect your reward.\n\n- Anon"
    }
    
    func setMessage(takenDown: Any, exposedBy: String) {
        self.newMissionDetailsRatio = ratios["exposed"]!
        self.titleColour = UIColor(red:0.83, green:0.11, blue:0.02, alpha:1.0)
        self.titleMessage = "SECURITY BREACH"
        self.backgroundImage = UIImage(named: "bad_full_pop_up")
        self.message = "Your mission has been Exposed by \(exposedBy), you have lost 50% of your gathered Evidence.\n\nReturn to \(homeBeacon), Agent."
    }
    
    func setMessage(successfulExpose: Any, reputation: Int) {
        self.newMissionDetailsRatio = ratios["expose_success"]!
        self.titleColour = UIColor(red:0.28, green:0.75, blue:0.18, alpha:1.0)
        self.titleMessage = "EXPOSE SUCCESS"
        self.backgroundImage = UIImage(named: "good_full_pop_up")
        self.message = "Good work, agent. Return to \(homeBeacon) for your next target.\n\nReward: \(reputation) reputation"
    }
    
    /* animations */
    
    func showAnimate() {
        let ratio = self.missionDetailsRatio.constraintWithMultiplier(self.newMissionDetailsRatio)
        self.missionDetails.removeConstraint(self.missionDetailsRatio)
        self.missionDetails.addConstraint(ratio)
        self.alertTitleLabel.text = self.titleMessage
        self.missionDetails.text = self.message
        self.alertBackgroundImage.image = self.backgroundImage
        self.alertTitleLabel.textColor = self.titleColour
        self.tapLabel.alpha = (self.tapToClose) ? 1 : 0
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

extension NSLayoutConstraint {
    func constraintWithMultiplier(_ multiplier: CGFloat) -> NSLayoutConstraint {
        return NSLayoutConstraint(item: self.firstItem!, attribute: self.firstAttribute, relatedBy: self.relation, toItem: self.secondItem, attribute: self.secondAttribute, multiplier: multiplier, constant: self.constant)
    }
}
