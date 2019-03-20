//
//  AlertViewController.swift
//  hackerhunt
//
//  Created by Louis Heath on 23/01/2019.
//  Copyright © 2019 Louis Heath. All rights reserved.
//

import UIKit

class AlertViewController: UIViewController {
    
    @IBOutlet weak var alertBackgroundImage: UIImageView!
    @IBOutlet weak var alertTitleLabel: UILabel!
    @IBOutlet weak var alertMessage: UITextView!
    @IBOutlet weak var tapLabel: UILabel!
    
    var message: String = "default string"
    var titleMessage: String = "default title"
    var homeBeacon = "A"
    var isShowing = false
    var tapToClose: Bool = false
    var backgroundImage: UIImage!
    var titleColour: UIColor!
    
    var titleColours: [String: UIColor] = ["neutral":UIColor(red:0.00, green:0.79, blue:0.85, alpha:1.0), "bad":UIColor(red:0.83, green:0.11, blue:0.02, alpha:1.0), "good":UIColor(red:0.28, green:0.75, blue:0.18, alpha:1.0)]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        alertMessage.isUserInteractionEnabled = false
        alertMessage.isScrollEnabled = false
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
        self.tapLabel.alpha = (self.tapToClose) ? 1 : 0
    }
    
    func setHomeBeacon(homeBeaconName: String) {
        self.homeBeacon = homeBeaconName
    }
    
    /* preset messages */
    
    func setMessage(message: String, tapToClose: Bool) {
        self.tapToClose = tapToClose
        self.message = message
    }
    
    func setMessage(gameOver: Any) {
        self.tapToClose = false
        self.message = "Incoming message...\n\nGood work! Return your equipment to the stand to collect your reward.\n\n- Anon"
    }
    
    func setMessage(gameStart: Any, tapToClose: Bool = false) {
        self.titleColour = titleColours["neutral"]!
        self.titleMessage = "GAME START"
        self.backgroundImage = UIImage(named: "neutral_full_pop_up")
        self.message = "Welcome, Agent. \nGo to game zone \(homeBeacon) for your first target."
        self.tapToClose = tapToClose
    }
    
    func setMessage(requestNewTarget: Any) {
        self.titleColour = titleColours["neutral"]!
        self.titleMessage = "TOO SLOW"
        self.backgroundImage = UIImage(named: "neutral_full_pop_up")
        self.message = "Your target was Exposed by another agent.\n\nReturn to \(homeBeacon) to be assigned a new target."
        self.tapToClose = false
    }
    
    func setMessage(takenDown: Any, exposedBy: String) {
        self.titleColour = titleColours["bad"]!
        self.titleMessage = "SECURITY BREACH"
        self.backgroundImage = UIImage(named: "bad_full_pop_up")
        self.message = "Your mission has been Exposed by \(exposedBy), you have lost 50% of your gathered Evidence.\n\nReturn to \(homeBeacon), Agent."
        self.tapToClose = false
    }
    
    func setMessage(successfulExpose: Any, reputation: Int) {
        self.titleColour = titleColours["good"]!
        self.titleMessage = "EXPOSE SUCCESS"
        self.backgroundImage = UIImage(named: "good_full_pop_up")
        self.message = "Good work, agent. Return to \(homeBeacon) for your next target.\n\nReward: \(reputation) reputation"
        self.tapToClose = false
    }
    
    func setMessage(newMission: String) {
        self.titleColour = titleColours["neutral"]!
        self.titleMessage = "MISSION UPDATE"
        self.backgroundImage = UIImage(named: "neutral_full_pop_up")
        self.message = newMission
        self.tapToClose = true
    }
    
    func setMessage(missionSuccess: Any, missionString: String) {
        self.titleColour = titleColours["good"]
        self.titleMessage = "MISSION SUCCESS"
        self.backgroundImage = UIImage(named: "good_full_pop_up")
        self.message = missionString
        self.tapToClose = true
    }
    
    func setMessage(missionFailure: Any, missionString: String) {
        self.titleColour = titleColours["bad"]!
        self.titleMessage = "MISSION FAILED"
        self.backgroundImage = UIImage(named: "bad_full_pop_up")
        self.message = missionString
        self.tapToClose = true
    }
    
    /* animations */
    
    func showAnimate() {
        self.alertTitleLabel.text = self.titleMessage
        self.alertMessage.text = self.message
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
        NSLayoutConstraint.deactivate([self])
        let newConstraint = NSLayoutConstraint(item: self.firstItem!, attribute: self.firstAttribute, relatedBy: self.relation, toItem: self.secondItem, attribute: self.secondAttribute, multiplier: multiplier, constant: self.constant)
        NSLayoutConstraint.activate([newConstraint])
        return newConstraint
    }
}
