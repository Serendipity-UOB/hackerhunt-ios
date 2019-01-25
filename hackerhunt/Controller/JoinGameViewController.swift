//
//  JoinGameViewController.swift
//  hackerhunt
//
//  Created by Louis Heath on 21/01/2019.
//  Copyright © 2019 Louis Heath. All rights reserved.
//

import Foundation
import UIKit

class JoinGameViewController: UIViewController {
    
    var gameState: GameState!
    
    var countTimer = Timer()
    var pollTimer = Timer()
    var timeLeft = -10
    var gameJoined = false
    
    @IBOutlet weak var welcomeLabel: UILabel!
    @IBOutlet weak var playerCountLabel: UILabel!
    @IBOutlet weak var timeRemainingLabel: UILabel!
    @IBOutlet weak var joinButton: UIButton!
    @IBOutlet weak var joinSuccessLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        welcomeLabel.text = "Welcome: \(gameState.player!.realName)"
        
        showJoinGameButton()
        
        startPollingGameInfo()
    }
    
    @IBAction func joinGamePressed(_ sender: Any) {
        joinButton.isEnabled = false
 
        let request = ServerUtils.post(to: "/joinGame", with: ["player_id": gameState.player!.id])
        
        URLSession.shared.dataTask(with: request) { (data, response, error) in
            
            guard let httpResponse = response as? HTTPURLResponse else { return }
            
            let statusCode: Int = httpResponse.statusCode
            
            if (statusCode == 200) {
                guard let data = data else { return }
                
                do {
                    let bodyJson = try JSONSerialization.jsonObject(with: data, options: [])
                    
                    guard let bodyDict = bodyJson as? [String: Any] else { return }
                    
                    guard let beaconName: String = bodyDict["home_beacon_name"] as? String else { return }
                    guard let beaconMinor: Int = bodyDict["home_beacon_minor"] as? Int else { return }
                    
                    DispatchQueue.main.async {
                        self.gameState.homeBeacon = HomeBeacon(name: beaconName, minor: beaconMinor)
                        self.gameJoined = true
                        self.hideJoinGameButton()
                    }
                } catch {}
            } else {
                DispatchQueue.main.async {
                    self.welcomeLabel.text = "Join game failed"
                    self.joinButton.isEnabled = true
                }
            }
        }.resume()
    }
    
    func startPollingGameInfo() {
        DispatchQueue.main.async {
            self.pollGameInfo()
            self.pollTimer = Timer.scheduledTimer(timeInterval: 5, target: self, selector: #selector(JoinGameViewController.pollGameInfo), userInfo: nil, repeats: true)
        }
    }
    
    @objc func pollGameInfo() {
        let request = ServerUtils.get(from: "/gameInfo")
        
        URLSession.shared.dataTask(with: request) { (data, response, error) in
            
            guard let httpResponse = response as? HTTPURLResponse else { return }
            
            let statusCode: Int = httpResponse.statusCode
            
            if (statusCode == 200) {
                guard let data = data else { return }
                
                do {
                    let bodyJson = try JSONSerialization.jsonObject(with: data, options: [])
                    
                    guard let bodyDict = bodyJson as? [String: Any] else { return }

                    guard let startTime: String = bodyDict["start_time"] as? String else { return }
                    guard let numPlayers: Int = bodyDict["number_players"] as? Int else { return }
                    
                    let timeRemaining : Int = calculateTimeRemaining(startTime: startTime)
                    self.gameState.endTime = calculateEndTime(startTime: startTime)
                    
                    DispatchQueue.main.async {
                        self.playerCountLabel.text = "\(numPlayers)"
                        
                        if (self.timeLeft < -5) {
                            self.startTiming(timeLeft: timeRemaining)
                        }
                    }
                } catch {}
            } else {
                DispatchQueue.main.async {
                    self.welcomeLabel.text = "Error, Report to base"
                }
            }
            
        }.resume()
    }
    
    /* Timing */
    
    func startTiming(timeLeft: Int) {
        self.timeLeft = timeLeft
        self.timeRemainingLabel.text = prettyTimeFrom(seconds: timeLeft)
        self.countTimer.invalidate()
        self.countTimer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(JoinGameViewController.decrementTimer), userInfo: nil, repeats: true)
    }
    
    @objc func decrementTimer() {
        timeLeft -= 1
        if (timeLeft >= 0) {
            timeRemainingLabel.text = prettyTimeFrom(seconds: timeLeft)
        }
        if (timeLeft <= 0 && gameJoined) {
            transitionToMainGame()
        }
    }
    
    /* Transition */
    
    func transitionToMainGame() {
        countTimer.invalidate()
        pollTimer.invalidate()
        self.performSegue(withIdentifier:"transitionToMainGame", sender:self);
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let mainGameViewController = segue.destination as? MainGameViewController {
            mainGameViewController.gameState = gameState
        }
    }
    
    /* UI */
    
    func showJoinGameButton() {
        DispatchQueue.main.async {
            self.joinButton.setTitle("join_game();", for: UIControl.State.normal)
            self.joinButton.alpha = 1
            self.joinSuccessLabel.alpha = 0
        }
    }
    
    func hideJoinGameButton() {
        DispatchQueue.main.async {
            self.joinButton.alpha = 0
            self.joinSuccessLabel.alpha = 1
        }
    }
}
