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
    @IBOutlet weak var logMessageRatio: NSLayoutConstraint!
    
    var ratios: [String:CGFloat] = ["exchange_requested":4.5, "exchange_accepted":3.6, "exchange_rejected":4.5, "intercept":4.5, "expose_failed":4.5]
    
    var message: String = ""
    var ratio: CGFloat = 1.0
    var image: UIImage!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    
    func setMesssage(exchangeRequestedWith: String) {
        self.image = UIImage(named: "notif-box")
        self.ratio = ratios["exchange_requested"]!
        self.message = "\nExchange with " + exchangeRequestedWith + " requested."
    }
    
    func setMessage(exchangeSuccessfulWithPlayer: String, evidence: [String]) {
        self.image = UIImage(named: "good_full_pop_up")
        self.ratio = ratios["exchange_accepted"]!
        self.message = "Exchange successful.\n\(exchangeSuccessfulWithPlayer) gave you evidence on "
        
        for e in evidence {
            if (e != exchangeSuccessfulWithPlayer) {
                self.message += e + " and "
            }
        }
        if (evidence.count != 1) {
            self.message.removeLast(5)
        }
        self.message += ".\nYou also found some about \(exchangeSuccessfulWithPlayer)."
    }
    
    func setMessage(exchangeRejected: String) {
        self.image = UIImage(named: "bad_full_pop_up")
        self.ratio = ratios["exchange_rejected"]!
        self.message = "Exchange failed.\n\(exchangeRejected) has rejected your request."
    }
    
    func setMessage(exchangeTimeout: String) {
        self.image = UIImage(named: "bad_full_pop_up")
        self.ratio = ratios["exchange_rejected"]!
        self.message = "Exchange failed.\n\(exchangeTimeout) didn't respond fast enough."
    }
    
    func setMessage(interceptRequestedOn: String) {
        self.image = UIImage(named: "notif-box")
        self.ratio = ratios["intercept"]!
        self.message = "Attempting to intercept \(interceptRequestedOn)'s Exchange."
    }
    
    func setMessage(interceptSuccessfulOn: String, withEvidenceOn: [String]) {
        self.image = UIImage(named: "good_full_pop_up")
        self.ratio = ratios["intercept"]!
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
        self.ratio = ratios["intercept"]!
        self.message = "Intercept on \(interceptFailedOn) failed, \(interceptFailedOn) wasn't exchanging."
    }
    
    func setMessage(interceptFailed: Any) {
        self.image = UIImage(named: "bad_full_pop_up")
        self.ratio = ratios["intercept"]!
        self.message = "Intercept failed, no evidence was shared."
    }
    
    func setMessage(exposeFailedWithInsufficientIntel: String) {
        self.image = UIImage(named: "bad_full_pop_up")
        self.ratio = ratios["expose_failed"]!
        self.message = "Expose failed.\nInsufficient evidence on \(exposeFailedWithInsufficientIntel)."
    }
    
    /* animations */
    
    func showAnimate() {
        NSObject.cancelPreviousPerformRequests(withTarget: self)
        self.backgroundImage.image = self.image
        self.logMessage.text = self.message
        self.logMessageRatio = self.logMessageRatio.constraintWithMultiplier(self.ratio)
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
