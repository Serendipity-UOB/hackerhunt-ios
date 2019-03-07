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
    
    var startTimer = Timer()
    var pollTimer = Timer()
    var gameStartTime: Double = -1
    var gameJoined = false
    
    @IBOutlet weak var welcomeLabel: UILabel!
    @IBOutlet weak var playerCountLabel: UILabel!
    @IBOutlet weak var timeRemainingLabel: UILabel!
    @IBOutlet weak var joinButton: UIButton!
    @IBOutlet weak var joinSuccessLabel: UILabel!
    @IBOutlet weak var globeGif: UIImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        globeGif.loadGif(name: "globe")
        
        welcomeLabel.text = (ServerUtils.testing) ? "Testing mode: \(gameState.player!.realName)" : "Welcome: \(gameState.player!.realName)"
        
        showJoinGameButton()
        
        startPollingGameInfo()
    }
    
    @IBAction func joinGamePressed(_ sender: Any) {
        if (gameStartTime == -1) {
            return
        }
        
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
                    guard let beaconMajor: Int = bodyDict["home_beacon_major"] as? Int else { return }
                    
                    DispatchQueue.main.async {
                        self.gameState.homeBeacon = HomeBeacon(name: beaconName, major: beaconMajor)
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
            self.pollTimer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(JoinGameViewController.pollGameInfo), userInfo: nil, repeats: true)
            self.pollTimer.fire()
        }
    }
    
    @objc func pollGameInfo() {
        let request = ServerUtils.get(from: "/gameInfo")
        
        URLSession.shared.dataTask(with: request) { (data, response, error) in
            
            if (!self.pollTimer.isValid) {
                return // game is beginning, don't consider next game
            }
            
            guard let httpResponse = response as? HTTPURLResponse else { return }
            
            let statusCode: Int = httpResponse.statusCode

            if (statusCode == 200) {
                guard let data = data else { return }
                
                do {
                    let bodyJson = try JSONSerialization.jsonObject(with: data, options: [])
                    
                    guard let bodyDict = bodyJson as? [String: Any] else { return }
                    guard let startTime: String = bodyDict["start_time"] as? String else { return }
                    guard let numPlayers: Int = bodyDict["number_players"] as? Int else { return }
                    
                    let startTimeDouble : Double = timeStringToDouble(time: startTime)
                    
                    DispatchQueue.main.async {
                        self.playerCountLabel.text = "\(numPlayers)"
                        self.gameIsScheduled()
                        
                        // if no game yet scheduled or server has scheduled a new game
                        if (self.gameStartTime == -1 || (startTimeDouble != self.gameStartTime && !ServerUtils.testing)) {
                            self.gameStartTime = startTimeDouble
                            self.gameState.endTime = calculateEndTime(startTime: startTime)
                            self.startTiming()
                        }
                    }
                } catch {}
            } else if (statusCode == 204) {
                DispatchQueue.main.async {
                    self.noGameIsScheduled()
                }
            } else {
                DispatchQueue.main.async {
                    self.welcomeLabel.text = "Error retrieving game info"
                }
            }
            
        }.resume()
    }
    
    /* Timing */
    
    func startTiming() {
        self.startTimer.invalidate()
        self.startTimer = Timer.scheduledTimer(timeInterval: 0.5, target: self, selector: #selector(JoinGameViewController.updateGameTimer), userInfo: nil, repeats: true)
        self.startTimer.fire()
    }
    
    @objc func updateGameTimer() {
        let timeRemaining = self.gameStartTime - now()
        if (timeRemaining >= 0) {
            timeRemainingLabel.text = prettyTimeFrom(seconds: Int(timeRemaining))
        }
        if (timeRemaining <= 0) {
            if (gameJoined) {
                transitionToMainGame()
            }
            self.gameStartTime = -1
            self.startTimer.invalidate()
        }
    }
    
    /* Transition */
    
    func transitionToMainGame() {
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
            self.joinButton.setTitle("Join game", for: UIControl.State.normal)
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
    
    func noGameIsScheduled() {
        self.timeRemainingLabel.text = "-"
        self.joinButton.isEnabled = false
        self.joinButton.setTitle("No game", for: UIControl.State.disabled)
    }
    
    func gameIsScheduled() {
        self.joinButton.isEnabled = true
        self.joinButton.setTitle("waiting...", for: UIControl.State.disabled)
    }
}
