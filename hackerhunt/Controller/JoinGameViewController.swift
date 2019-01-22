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
    
    var timer = Timer()
    var timeLeft = 0
    var gameJoined = false
    
    @IBOutlet weak var welcomeLabel: UILabel!
    @IBOutlet weak var playerCountLabel: UILabel!
    @IBOutlet weak var timeRemainingLabel: UILabel!
    @IBOutlet weak var joinButton: UIButton!
    @IBOutlet weak var joinSuccessLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        welcomeLabel.text = "Welcome: \(gameState.player!.realName!)"
        joinButton.isEnabled = false
        joinSuccessLabel.alpha = 0
        
        let request = ServerUtils.get(from: "/gameInfo")
        
        // make async request
        URLSession.shared.dataTask(with: request) { (data, response, error) in
            if let data = data {
                do {
                    let bodyJson = try JSONSerialization.jsonObject(with: data, options: [])
                    
                    if let bodyDict = bodyJson as? [String: Any] {
                        if let statusCode = bodyDict["status"] as? Int {
                            
                            if (statusCode == 200 || statusCode == 404) {
                                // read in start_time and num_players, output to screen
                                let dummyInfo: [String: String] = [
                                    "number_players": "2",
                                    "start_time": "wow"
                                ]
                                DispatchQueue.main.async {
                                    self.playerCountLabel.text = dummyInfo["number_players"]!
                                    self.joinButton.isEnabled = true
                                    self.startTiming(timeLeft: 5)
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
        timer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(JoinGameViewController.decrementTimer), userInfo: nil, repeats: true)
    }
    @objc func decrementTimer() {
        timeLeft -= 1
        if (timeLeft >= 0) {
            timeRemainingLabel.text = String(timeLeft)
        }
        if (timeLeft <= 0 && gameJoined) {
            timer.invalidate()
            self.performSegue(withIdentifier:"transitionToMainGame", sender:self);
        }
        
    }
    
    @IBAction func joinGameClicked(_ sender: Any) {
        // POST /joinGame
        
        
        gameJoined = true
        joinButton.alpha = 0
        joinSuccessLabel.alpha = 1
    }
}
