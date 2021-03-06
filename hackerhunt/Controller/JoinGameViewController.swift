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

    var pollTimer = Timer()
    
    @IBOutlet weak var timeRemainingTitleLabel: UILabel!
    @IBOutlet weak var playerCountTitleLabel: UILabel!
    @IBOutlet weak var welcomeLabel: UILabel!
    @IBOutlet weak var playerCountLabel: UILabel!
    @IBOutlet weak var timeRemainingLabel: UILabel!
    @IBOutlet weak var joinButton: UIButton!
    @IBOutlet weak var joinSuccessLabel: UILabel!
    @IBOutlet weak var globeGif: UIImageView!
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        let modelName = UIDevice.modelName
        if (modelName == "iPhone SE") {
            playerCountTitleLabel.font = playerCountTitleLabel.font.withSize(16)
            timeRemainingTitleLabel.font = timeRemainingTitleLabel.font.withSize(16)
        }
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        globeGif.loadGif(name: "globe")
        
        welcomeLabel.text = (ServerUtils.testing) ? "Testing mode: \(gameState.player!.realName)" : "Welcome, agent \(gameState.player!.realName)"
        
        showJoinGameButton()
        
        joinButton.sendActions(for: .touchUpInside)
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
                    guard let homeZoneName: String = bodyDict["home_zone_name"] as? String else {
                        print("home_zone_name missing")
                        return
                    }
                    
                    self.startPollingGameInfo()
                    
                    DispatchQueue.main.async {
                        self.gameState.homeBeacon = homeZoneName
                        self.hideJoinGameButton()
                    }
                } catch {}
            } else {
                DispatchQueue.main.async {
                    self.welcomeLabel.text = "Join game failed"
                    print("/joinGame response code \(statusCode)")
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
                    guard let countdown: String = bodyDict["countdown"] as? String else {
                        print("countdown missing")
                        return
                    }
                    guard let numPlayers: Int = bodyDict["number_players"] as? Int else {
                        print("number_players missing")
                        return
                    }
                    guard let gameStarting: Bool = bodyDict["game_start"] as? Bool else {
                        print("game_start missing")
                        return
                    }
                    
                    DispatchQueue.main.async {
                        self.playerCountLabel.text = "\(numPlayers)"
                        self.timeRemainingLabel.text = countdown
                        self.joinSuccessLabel.text = (countdown == "--:--") ? "Waiting for players" : "Game starting"

                        self.gameIsScheduled()
                        
                        if (gameStarting) {
                            self.transitionToMainGame()
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
