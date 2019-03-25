//
//  LogViewController.swift
//  hackerhunt
//
//  Created by Thomas Walker on 14/03/2019.
//  Copyright © 2019 Louis Heath. All rights reserved.
//

import Foundation
import UIKit

class LogViewController : UIViewController {
    
    @IBOutlet weak var backgroundImage: UIImageView!
    @IBOutlet weak var logMessage: UITextView!
    
    var message: String = ""
    var image: UIImage!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        logMessage.isScrollEnabled = false
    }
    
    
    func setMesssage(exchangeRequestedWith: String) {
        self.image = UIImage(named: "notif-box")
        self.message = "\nExchange with " + exchangeRequestedWith + " requested."
    }
    
    func setMessage(exchangeSuccessfulWithPlayer: String, evidence: [String]) {
        self.image = UIImage(named: "good_full_pop_up")
        if (evidence.count != 1) {
            self.message = "Exchange successful.\n\(exchangeSuccessfulWithPlayer) gave you evidence on "
            for e in evidence {
                if (e != exchangeSuccessfulWithPlayer) {
                    self.message += e + " and "
                }
            }
            self.message.removeLast(5)
            self.message += ".\nYou also found some about \(exchangeSuccessfulWithPlayer)."
        }
        else {
            self.message = "Exchange successful.\nYou found some evidence on \(exchangeSuccessfulWithPlayer)."
        }

    }
    
    func setMessage(exchangeRejected: String) {
        self.image = UIImage(named: "bad_full_pop_up")
        self.message = "Exchange failed.\n\(exchangeRejected) has rejected your request."
    }
    
    func setMessage(exchangeTimeout: String) {
        self.image = UIImage(named: "bad_full_pop_up")
        self.message = "Exchange failed.\n\(exchangeTimeout) didn't respond fast enough."
    }
    
    func setMessage(interceptRequestedOn: String) {
        self.image = UIImage(named: "notif-box")
        self.message = "Attempting to intercept \(interceptRequestedOn)'s Exchange."
    }
    
    func setMessage(interceptSuccessfulOn: String, withEvidenceOn: [String]) {
        self.image = UIImage(named: "good_full_pop_up")
        self.message = "Intercept on \(interceptSuccessfulOn) succeeded.\nYou also gained evidence about "
        for e in withEvidenceOn {
            if (e != interceptSuccessfulOn) {
                self.message += e + " and "
            }
        }
        self.message.removeLast(5)
        self.message += "."
    }
    
    func setMessage(interceptFailedOn: String) {
        self.image = UIImage(named: "bad_full_pop_up")
        self.message = "Intercept on \(interceptFailedOn) failed, \(interceptFailedOn) wasn't exchanging."
    }
    
    func setMessage(interceptFailed: Any) {
        self.image = UIImage(named: "bad_full_pop_up")
        self.message = "Intercept failed, no evidence was shared."
    }
    
    func setMessage(exposeFailedWithInsufficientIntel: String) {
        self.image = UIImage(named: "bad_full_pop_up")
        self.message = "Expose failed.\nInsufficient evidence on \(exposeFailedWithInsufficientIntel)."
    }
    
    func setMessage(exchangeAcceptedWithPlayer: String, evidence: [String]) {
        self.image = UIImage(named: "good_full_pop_up")
        if (evidence.count != 1) {
            self.message = "Exchange successful.\n\(exchangeAcceptedWithPlayer) gave you evidence on "
            for e in evidence {
                if (e != exchangeAcceptedWithPlayer) {
                    self.message += e + " and "
                }
            }
            self.message.removeLast(5)
            self.message += ".\nYou also found some about \(exchangeAcceptedWithPlayer)."
        }
        else {
            self.message = "Exchange successful.\nYou found some evidence on \(exchangeAcceptedWithPlayer)"
        }
        
    }
    
    func setMessage(exchangeRejectedWithPlayer: String) {
        self.image = UIImage(named: "bad_full_pop_up")
        self.message = "You rejected \(exchangeRejectedWithPlayer)'s exchange."
    }
    
    func setMessage(farAwayPlayerSelected: String) {
        self.image = UIImage(named: "notif-box")
        self.message = "\(farAwayPlayerSelected) is too far away, find them to interact."
    }
    
    func setMessage(exposeFailedWithWrongPerson: String) {
        self.image = UIImage(named: "bad_full_pop_up")
        self.message = "Expose failed.\n\(exposeFailedWithWrongPerson) is not your target."
    }
    
    func setMessage(cantHaveMultipleExchanges: Any) {
        self.image = UIImage(named: "notif-box")
        self.message = "You can only send one exchange request at a time, wait for your current one to complete."
    }
    
    /* animations */
    
    func showAnimate() {
        NSObject.cancelPreviousPerformRequests(withTarget: self)
        self.backgroundImage.image = self.image
        self.logMessage.text = self.message
        self.view.transform = CGAffineTransform(scaleX: 1.3, y: 1.3)
        self.view.alpha = 0.0;
        UIView.animate(withDuration: 0.25, animations: {
            self.view.alpha = 1.0
            self.view.transform = CGAffineTransform(scaleX: 1.0, y: 1.0)
        }, completion: {_ in
            self.perform(#selector(LogViewController.removeAnimate), with: nil, afterDelay: 3)
        });
    }
    
    @objc func removeAnimate() {
        NSObject.cancelPreviousPerformRequests(withTarget: self)
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
