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
    
    func setMessage(exposeFailedWithInsufficientIntel: String) {
        self.image = UIImage(named: "bad_full_pop_up")
        self.message = "Expose failed.\nInsufficient evidence on \(exposeFailedWithInsufficientIntel)."
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
    
    func setMessage(networkError: Any) {
        self.image = UIImage(named: "bad_full_pop_up")
        self.message = "Network error on request response"
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
