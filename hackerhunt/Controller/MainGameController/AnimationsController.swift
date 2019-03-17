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
    
    // MARK: Exchange requested
    
    func showExchangeRequested() {
        self.exchangeRequestedBackground.alpha = 1.0
        self.exchangeRequestedAcceptButton.alpha = 1.0
        self.exchangeRequestedAcceptButton.isUserInteractionEnabled = true
        self.exchangeRequestedRejectButton.alpha = 1.0
        self.exchangeRequestedRejectButton.isUserInteractionEnabled = true
        self.exchangeRequestedText.alpha = 1.0
    }
    
    func hideExchangeRequested() {
        self.exchangeRequestedBackground.alpha = 0.0
        self.exchangeRequestedAcceptButton.alpha = 0.0
        self.exchangeRequestedAcceptButton.isUserInteractionEnabled = false
        self.exchangeRequestedRejectButton.alpha = 0.0
        self.exchangeRequestedRejectButton.isUserInteractionEnabled = false
        self.exchangeRequestedText.alpha = 0.0
    }
}
