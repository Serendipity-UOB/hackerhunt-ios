//
//  InteractionController.swift
//  hackerhunt
//
//  Created by Thomas Walker on 12/03/2019.
//  Copyright © 2019 Louis Heath. All rights reserved.
//

import Foundation

extension MainGameViewController {
    
    // MARK: Exchange
    
    func exchange(withPlayerAtIndex tableIndex: Int) {
        let interacteeId = self.gameState.allPlayers[tableIndex].id
        
        if (gameState.playerIsNearby(interacteeId)) {
            let validContacts: [[String: Int]] = self.gameState.allPlayers
                .filter({ $0.intel > 0.0 })
                .map({ return ["contact_id": $0.id] })
            
            let data: [String:Any] = [
                "interacter_id": self.gameState.player!.id,
                "interactee_id": interacteeId,
                "contact_ids": validContacts
            ]
            
            // send request
            exchangeTimer.invalidate()
            exchangeTimer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(MainGameViewController.exchangeRequest), userInfo: data, repeats: true)
            exchangeTimer.fire()
        } else {
            DispatchQueue.main.async {
                self.terminalVC.setMessage(message: "EXCHANGE_FAIL\n\nPlayer not nearby", tapToClose: true)
            }
        }
    }
    
    @objc func exchangeRequest() {
        let data: [String:Any] = exchangeTimer.userInfo as! [String:Any]
        let interactee: Int = data["interactee_id"] as! Int
        let request = ServerUtils.post(to: "/exchange", with: data)
        
        URLSession.shared.dataTask(with: request) { (data, response, error) in
            
            guard let httpResponse = response as? HTTPURLResponse else { return }
            
            let statusCode: Int = httpResponse.statusCode
            print("exchange code " + String(statusCode))
            
            switch statusCode {
            case 200:
                guard let responseData = data else { return }
                do {
                    self.exchangeTimer.invalidate()
                    
                    let bodyJson = try JSONSerialization.jsonObject(with: responseData, options: [])
                    
                    guard let bodyDict = bodyJson as? [String: Any] else { return }
                    guard let secondaryId = bodyDict["secondary_id"] as? Int else {
                        print("secondary_id missing")
                        return
                    }
                    
                    self.gameState.incrementIntelFor(playerOne: interactee, playerTwo: secondaryId)
                    self.gameState.unhideAll()
                    self.exchange = false
                    
                    DispatchQueue.main.async {
                        self.contractExchangeButton()
                        self.playerTableView.reloadData()
                        self.terminalVC.setMessage(message: "EXCHANGE_SUCCESS\n\nIntel gained", tapToClose: true)
                        if (self.exchangeMessage) { // don't do showTerminal if it's already up
                            print("updating terminal text")
                            self.terminalVC.viewWillAppear(false)
                        } else {
                            print("showing terminal")
                            self.showTerminal()
                        }
                        self.exchangeMessage = false
                    }
                } catch {}
            case 201, 202:
                if (!self.exchangeMessage) { // don't do show terminal if it's already up
                    DispatchQueue.main.async {
                        print("showing terminal")
                        self.exchangeMessage = true
                        self.terminalVC.setMessage(message: "EXCHANGE_REQUESTED\n\nWaiting for handshake", tapToClose: false)
                        self.showTerminal()
                    }
                }
            case 400:
                self.exchangeTimer.invalidate()
                DispatchQueue.main.async {
                    print("exchange failed")
                    self.exchange = false
                    self.contractExchangeButton()
                    
                    self.terminalVC.setMessage(message: "EXCHANGE_FAIL\n\nHandshake incomplete", tapToClose: true)
                    self.terminalVC.viewWillAppear(false)
                    self.exchangeMessage = false
                }
            default:
                print("/exchange unexpected \(statusCode)")
            }
            }.resume()
    }
    
    // MARK: Takedown
    
    func takeDown(target: Int) {
        // attempt to takedown far away person
        if (self.gameState.allPlayers[target].nearby == false) {
            DispatchQueue.main.async {
                self.gameState.unhideAll()
                self.playerTableView.reloadData()
                self.terminalVC.setMessage(message: "TAKEDOWN_FAILURE\n\nGet closer to your target", tapToClose: true)
                self.showTerminal()
                self.takedown = false
                self.contractTakeDownButton()
            }
            return
        }
        // attempt to takedown with insufficient intel
        if (self.gameState.allPlayers[target].intel < 1.0) {
            DispatchQueue.main.async {
                self.gameState.unhideAll()
                self.playerTableView.reloadData()
                self.terminalVC.setMessage(message: "TAKEDOWN_FAILURE\n\nInsufficient intel", tapToClose: true)
                self.showTerminal()
                self.takedown = false
                self.contractTakeDownButton()
            }
            return
        }
        // attempt to take down wrong person
        if (self.gameState.allPlayers[target].codeName != self.gameState.currentTarget!.codeName) {
            DispatchQueue.main.async {
                self.gameState.unhideAll()
                self.playerTableView.reloadData()
                self.terminalVC.setMessage(message: "TAKEDOWN_FAILURE\n\nNot your target", tapToClose: true)
                self.showTerminal()
                self.takedown = false
                self.contractTakeDownButton()
            }
            return
        }
        
        DispatchQueue.main.async {
            self.terminalVC.setMessage(message: "TAKEDOWN_INIT\n\nExecuting attack...", tapToClose: true)
            self.showTerminal()
        }
        
        // create data
        let data: [String: Int] = [
            "player_id": self.gameState.player!.id,
            "target_id": self.gameState.allPlayers[target].id
        ]
        print("taking down with data:\n\t\(data)\n")
        
        let request = ServerUtils.post(to: "/takeDown", with: data)
        
        URLSession.shared.dataTask(with: request) { (data, response, error) in
            
            guard let httpResponse = response as? HTTPURLResponse else { return }
            
            let statusCode: Int = httpResponse.statusCode
            
            print("taken down status code " + String(statusCode))
            
            if (statusCode == 200) {
                
                guard let responseData = data else { return }
                do {
                    
                    let bodyJson = try JSONSerialization.jsonObject(with: responseData, options: [])
                    
                    guard let bodyDict = bodyJson as? [String: Any] else { return }
                    guard let reputation = bodyDict["reputation"] as? Int else { return }
                    
                    DispatchQueue.main.async {
                        self.terminalVC.setMessage(successfulExpose: true, reputation: reputation)
                        self.showTerminal()
                        self.playerTableView.reloadData()
                        self.startCheckingForHomeBeacon(withCallback: self.requestNewTarget)
                        self.gameState.unhideAll()
                        self.takedown = false
                        self.contractTakeDownButton()
                    }
                } catch {}
            } else {
                print("take down failed\n\(String(describing: response))")
            }
            }.resume()
    }
    
}
