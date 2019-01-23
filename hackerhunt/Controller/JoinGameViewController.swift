//
//  JoinGameViewController.swift
//  hackerhunt
//
//  Created by Louis Heath on 21/01/2019.
//  Copyright © 2019 Louis Heath. All rights reserved.
//

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
        
        welcomeLabel.text = "Welcome: \(gameState.player!.realName!)"
        showJoinGameButton()
        
        startPollingGameInfo()
    }
    
    @IBAction func joinGameClicked(_ sender: Any) {
        joinButton.isEnabled = false
 
        let request = ServerUtils.post(to: "/joinGame", with: ["player_id": gameState.player!.id!])
        
        URLSession.shared.dataTask(with: request) { (data, response, error) in
            if let data = data {
                do {
                    let bodyJson = try JSONSerialization.jsonObject(with: data, options: [])
                    
                    if let bodyDict = bodyJson as? [String: Any] {
                        
                        if let statusCode = bodyDict["status"] as? Int {
                            
                            if (statusCode == 200 || statusCode == 404) {
                                let dummyHomeBeacon = "A"
                                DispatchQueue.main.async {
                                    self.gameState.homeBeacon = dummyHomeBeacon
                                    self.gameJoined = true
                                    self.hideJoinGameButton()
                                }
                                
                            } else {
                                DispatchQueue.main.async {
                                    self.welcomeLabel.text = "Join game failed"
                                    self.joinButton.isEnabled = true
                                }
                            }
                        }
                    }
                } catch {}
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
            
            if let data = data {
                do {
                    let bodyJson = try JSONSerialization.jsonObject(with: data, options: [])
                    
                    if let bodyDict = bodyJson as? [String: Any] {
                        
                        if let statusCode = bodyDict["status"] as? Int {
                            
                            if (statusCode == 200 || statusCode == 404) {
                                // read in start_time and num_players from body, update UI
                                let dummyInfo: [String: Any] = [
                                    "number_players": "2",
                                    "start_time": 5
                                ]
                                DispatchQueue.main.async {
                                    self.playerCountLabel.text = dummyInfo["number_players"] as? String

                                    if (self.timeLeft < -5) {
                                        self.startTiming(timeLeft: dummyInfo["start_time"] as! Int)
                                    }
                                }
                                
                            } else {
                                DispatchQueue.main.async {
                                    self.welcomeLabel.text = "Error, Report to base"
                                }
                            }
                        }
                    }
                } catch {}
            }
        }.resume()
        
    }
    
    func startTiming(timeLeft: Int) {
        self.timeLeft = timeLeft
        self.timeRemainingLabel.text = String(timeLeft)
        self.countTimer.invalidate()
        self.countTimer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(JoinGameViewController.decrementTimer), userInfo: nil, repeats: true)
    }
    
    @objc func decrementTimer() {
        timeLeft -= 1
        if (timeLeft >= 0) {
            timeRemainingLabel.text = String(timeLeft)
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
        joinButton.alpha = 1
        joinSuccessLabel.alpha = 0
    }
    
    func hideJoinGameButton() {
        joinButton.alpha = 0
        joinSuccessLabel.alpha = 1
    }
}
