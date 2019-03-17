//
//  PlayerUpdateController.swift
//  hackerhunt
//
//  Created by Thomas Walker on 12/03/2019.
//  Copyright © 2019 Louis Heath. All rights reserved.
//

import Foundation
import UIKit

extension MainGameViewController {
    
    // MARK: Countdown
    
    func startGameOverCountdown() {
        self.countdownTimer.invalidate()
        self.countdownTimer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(MainGameViewController.updateGameTimer), userInfo: nil, repeats: true)
        self.countdownTimer.fire()
    }
    
    @objc func updateGameTimer() {
        let timeRemaining = self.gameState.endTime! - Int(now())
        if (timeRemaining >= 0) {
            countdownValue.text = prettyTimeFrom(seconds: timeRemaining)
        }
    }
    
    // MARK: Alert Animations
    
    func showAlert() {
        self.addChild(alertVC)
        self.view.addSubview(alertVC.view)
        alertVC.didMove(toParent: self)
        alertVC.showAnimate()
        alertVC.isShowing = true
    }
    
    func showLog() {
        self.addChild(logVC)
        self.view.addSubview(logVC.view)
        logVC.didMove(toParent: self)
        logVC.showAnimate()
        
    }
    
    
    // MARK: Button animations
    
    func expandExchangeButton() {
        takeDownBtn.isEnabled = false
        UIView.animate(withDuration: 0.25, animations: {
            // these constants are the offset - i.e. relative to the
            self.exchangeBtnWidth.constant = self.view.frame.width / 2 - 20
            self.takeDownBtnWidth.constant = -1 * self.view.frame.width / 2
            self.exchangeBtn.setTitle("cancel(EXCHANGE);", for: .normal)
        })
    }
    
    func contractExchangeButton() {
        takeDownBtn.isEnabled = true
        self.exchangeBtn.setTitle("exchange();", for: .normal)
        UIView.animate(withDuration: 0.25, animations: {
            self.exchangeBtnWidth.constant = -15
            self.takeDownBtnWidth.constant = -15
        })
    }
    
    func expandTakeDownButton() {
        exchangeBtn.isEnabled = false
        UIView.animate(withDuration: 0.25, animations: {
            self.takeDownBtnWidth.constant = self.view.frame.width / 2 - 20
            self.exchangeBtn.alpha = 0
            self.takeDownBtn.setTitle("cancel(TAKEDOWN);", for: .normal)
        })
    }
    
    func contractTakeDownButton() {
        exchangeBtn.isEnabled = true
        self.takeDownBtn.setTitle("take_down();", for: .normal)
        UIView.animate(withDuration: 0.25, animations: {
            self.takeDownBtnWidth.constant = -15
            self.exchangeBtn.alpha = 1
        })
    }
}
