//
//  InteractionController.swift
//  hackerhunt
//
//  Created by Thomas Walker on 12/03/2019.
//  Copyright © 2019 Louis Heath. All rights reserved.
//

import Foundation
import UIKit

extension MainGameViewController {
    
    // MARK: Exchange
    @objc func exchangeButtonAction(sender: UIButton!) {
        self.ungreyOutAllCells()
        let interacteeId = sender.tag
        let player = self.gameState.getPlayerById(interacteeId)!
        
        
        
        if (gameState.playerIsNearby(interacteeId)) {
            DispatchQueue.main.async {
                self.setCurrentlyExchanging(with: player)
                self.playerTableView.reloadData()
            }
            
            let validContacts: [[String: Int]] = self.gameState.allPlayers
                .filter({ $0.evidence > 0 })
                .map({ return ["contact_id": $0.id] })
            
            let data: [String:Any] = [
                "requester_id": self.gameState.player!.id,
                "responder_id": interacteeId,
                "contact_ids": validContacts
            ]
            
            // send request
            exchangeTimer.invalidate()
            exchangeTimer = Timer.scheduledTimer(timeInterval: 0.8, target: self, selector: #selector(MainGameViewController.exchangeRequest), userInfo: data, repeats: true)
            exchangeTimer.fire()
            exchangeTimer.tolerance = 0.5
        }
    }
    
    @objc func exchangeRequest() {
        let requestdata: [String:Any] = exchangeTimer.userInfo as! [String:Any]
        let player = self.gameState.getPlayerById(requestdata["responder_id"]! as! Int)!
        let request = ServerUtils.post(to: "/exchangeRequest", with: requestdata)
        
        URLSession.shared.dataTask(with: request) { (data, response, error) in
            
            guard let httpResponse = response as? HTTPURLResponse else {
                self.logVC.setMessage(networkError: true)
                self.showLog()
                return
                
            }
            
            let statusCode: Int = httpResponse.statusCode
            print("exchange code " + String(statusCode))
            
            switch statusCode {
            case 201: // created
                print("Exchange requested")
            case 202: // accepted
                guard let responseData = data else { return }
                do {
                    self.exchangeTimer.invalidate()
                    
                    let bodyJson = try JSONSerialization.jsonObject(with: responseData, options: [])
                    
                    guard let bodyDict = bodyJson as? [String: Any] else { return }
                    guard let evidence = bodyDict["evidence"] as? [[String:Any]] else {
                        print("evidence missing")
                        return
                    }
                    var players: [String] = []
                    for e in evidence {
                        let playerId: Int = e["player_id"] as! Int
                        if let p = self.gameState.getPlayerById(playerId) {
                            players.append(p.realName)
                            let amount: Int = e["amount"] as! Int
                            self.gameState.incrementEvidence(player: playerId, evidence: amount)
                        } else {
                            print("couldn't find player \(playerId)")
                            return
                        }
                    }
                    
                    DispatchQueue.main.async {
                        self.setNoLongerExchanging(with: player, true)
                        print("Exchange accepted")
                    }
                } catch {}
            case 204: // rejected
                self.exchangeTimer.invalidate()
                DispatchQueue.main.async {
                    self.setNoLongerExchanging(with: player, false)
                    print("Exchange rejected, put small popup here")
                }
            case 206:
                DispatchQueue.main.async {
                    self.playerTableView.reloadData()
                }
                print("EXCHANGE REQUEST keep polling")
            case 400: // error
                self.exchangeTimer.invalidate()
                
                DispatchQueue.main.async {
                    self.setNoLongerExchanging(with: player, false)
                }
                print("You did a bad exchange")
            case 404: // exchange already pending
                self.exchangeTimer.invalidate()
                
                DispatchQueue.main.async {
                    self.setNoLongerExchanging(with: player, false)
                }
                print("Exchange already pending")
            case 408: // timeout
                self.exchangeTimer.invalidate()
                DispatchQueue.main.async {
                    self.setNoLongerExchanging(with: player, false)
                    print("Exchange timed out, put small popup here")
                }
            default:
                self.exchangeTimer.invalidate()
                print("/exchangeRequest unexpected \(statusCode)")
                DispatchQueue.main.async {
                    self.setNoLongerExchanging(with: player, false)
                }
            }
            }.resume()
    }
    
    func setCurrentlyExchanging(with player: Player) {
        let p = gameState.getPlayerById(player.id)
        p!.exchangeRequested = true
        p!.interceptDisabled = true
        for p in self.gameState.allPlayers {
            p.exchangeDisabled = true
        }
    }
    
    func setNoLongerExchanging(with player: Player, _ success: Bool) {
        var p = gameState.getPlayerById(player.id)
        p!.exchangeRequested = false
        p!.interactionResult = success ? 1 : 2
        enableEnableableButtons()
//        var interceptCurrentlyPending = false
//        for player in self.gameState.allPlayers {
//            if (player.interceptRequested) {
//                interceptCurrentlyPending = true
//            }
//        }
//        for player in self.gameState.allPlayers {
//            // enable all exchanges apart from for a player who is being intercepted
//            if (!player.interceptRequested) {
//                player.exchangeDisabled = false
//            }
//            // enable all intercepts IF no intercept is pending
//            if (!interceptCurrentlyPending) {
//                player.interceptDisabled = false
//            }
//        }
        self.playerTableView.reloadData()
        self.playerTableView.layoutIfNeeded()
        p = gameState.getPlayerById(player.id)!
        p!.interactionResult = 0
    }
    
    func exchangeResponse(_ requesterId: Int) {
        let validContacts: [[String: Int]] = self.gameState.allPlayers
            .filter({ $0.evidence > 0 })
            .map({ return ["contact_id": $0.id] })
        
        let data: [String:Any] = [
            "responder_id": self.gameState.player!.id,
            "requester_id": requesterId,
            "contact_ids": validContacts
        ]
        
        self.exchangeRequestTimer.invalidate()
        self.exchangeRequestTimer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(MainGameViewController.exchangeResponseRequest), userInfo: data, repeats: true)
        self.exchangeRequestTimer.fire()
        exchangeRequestTimer.tolerance = 0.4
    }
    
    @objc func exchangeResponseRequest() {
        var requestdata: [String:Any] = exchangeRequestTimer.userInfo as! [String:Any]
        requestdata["response"] = self.exchangeResponse
        let request = ServerUtils.post(to: "/exchangeResponse", with: requestdata)
        
        URLSession.shared.dataTask(with: request) { (data, response, error) in
            
            guard let httpResponse = response as? HTTPURLResponse else {
                self.logVC.setMessage(networkError: true)
                self.showLog()
                return
            }
            
            let statusCode: Int = httpResponse.statusCode
            
            print("exchange response status code \(statusCode)")
            
            switch statusCode {
            case 202:
                print("exchange request accepted")
                self.exchangeRequestTimer.invalidate()
                self.exchangeResponse = 0
                guard let responseData = data else { return }
                do {
                    let bodyJson = try JSONSerialization.jsonObject(with: responseData, options: [])
                    guard let bodyDict = bodyJson as? [String: Any] else {
                        print("something went wrong accessing 202 response data exchange request")
                        return
                    }
                    guard let evidence = bodyDict["evidence"] as? [[String:Any]] else {
                        print("evidence missing for exchange request")
                        return
                    }
                    
                    var players: [String] = []
                    for e in evidence {
                        let playerId: Int = e["player_id"] as! Int
                        if let p = self.gameState.getPlayerById(playerId) {
                            players.append(p.realName)
                            let amount: Int = e["amount"] as! Int
                            self.gameState.incrementEvidence(player: playerId, evidence: amount)
                        } else {
                            print("couldn't find player \(playerId)")
                            return
                        }
                    }
                    
                    DispatchQueue.main.async {
                        self.playerTableView.reloadData()
                        self.hideExchangeRequested()
                    }
                } catch {}
            case 205:
                self.exchangeRequestTimer.invalidate()
                self.exchangeResponse = 0
                print("exchange request successfully rejected")
                DispatchQueue.main.async {
                    self.hideExchangeRequested()
                }
            case 206:
                print("EXCHANGE RESPONSE keep polling")
                guard let responseData = data else { return }
                do {
                    let bodyJson = try JSONSerialization.jsonObject(with: responseData, options: [])
                    guard let bodyDict = bodyJson as? [String: Any] else {
                        print("something went wrong accessing 206 response data exchange request")
                        return
                    }
                    guard let timeRemaining = bodyDict["time_remaining"] as? Int else {
                        print("time remaining missing in exchange response")
                        return
                    }
                    
                    DispatchQueue.main.async {
                        UIView.setAnimationsEnabled(false)
                        self.exchangeRequestedRejectButton.setTitle("REJECT \(timeRemaining)", for: .normal)
                        self.exchangeRequestedRejectButton.layoutIfNeeded()
                        UIView.setAnimationsEnabled(true)
                    }
                    
                } catch {}
            case 400:
                self.exchangeRequestTimer.invalidate()
                self.exchangeResponse = 0
                print("something we did was wrong in exchange response")
                DispatchQueue.main.async {
                    self.hideExchangeRequested()
                }
            case 408:
                self.exchangeRequestTimer.invalidate()
                self.exchangeResponse = 0
                print("exchange response timed out")
                DispatchQueue.main.async {
                    self.hideExchangeRequested()
                }
            default:
                self.exchangeRequestTimer.invalidate()
                self.exchangeResponse = 0
                print("something went wrong in exchange response with code \(statusCode)")
                DispatchQueue.main.async {
                    self.hideExchangeRequested()
                }
            }
            }.resume()
    }
    
    
    // MARK: Intercept
    
    @objc func interceptButtonAction(sender: UIButton!) {
        self.ungreyOutAllCells()
        
        let targetId = sender.tag
        let player : Player = gameState.getPlayerById(targetId)!
        print("intercepting \(player.realName) with id \(player.id) where targetid \(targetId)")
        
        if (!gameState.playerIsNearby(targetId)) {
            print("player not nearby")
            return
        }
        
        DispatchQueue.main.async {
            self.setCurrentlyIntercepting(player)
            self.playerTableView.reloadData()
        }
        
        let data: [String:Any] = [
            "player_id": self.gameState.player!.id,
            "target_id": targetId
        ]
        
        interceptTimer.invalidate()
        interceptTimer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(MainGameViewController.interceptRequest), userInfo: data, repeats: true)
        interceptTimer.fire()
        interceptTimer.tolerance = 0.4
    }
    
    @objc func interceptRequest() {
        let requestdata: [String:Any] = interceptTimer.userInfo as! [String:Any]
        print("intercept requested")
        print(requestdata)
        let request = ServerUtils.post(to: "/intercept", with: requestdata)
        
        let target = self.gameState.getPlayerById(requestdata["target_id"]! as! Int)!
        
        URLSession.shared.dataTask(with: request) { (data, response, error) in
            
            guard let httpResponse = response as? HTTPURLResponse else {
                self.logVC.setMessage(networkError: true)
                self.showLog()
                return
            }
            
            let statusCode: Int = httpResponse.statusCode
            
            switch statusCode {
            case 200:
                self.interceptTimer.invalidate()
                guard let responseData = data else { return }
                do {
                    let bodyJson = try JSONSerialization.jsonObject(with: responseData, options: [])
                    guard let bodyDict = bodyJson as? [String: Any] else {
                        print("something went wrong accessing 200 response data intercept")
                        return
                    }
                    guard let evidence = bodyDict["evidence"] as? [[String:Any]] else {
                        print("evidence missing for intercept")
                        return
                    }
                    
                    var playerNames: [String] = []
                    for e in evidence {
                        let playerId: Int = e["player_id"] as! Int
                        
                        if let p = self.gameState.getPlayerById(playerId) {
                            let amount: Int = e["amount"] as! Int
                            self.gameState.incrementEvidence(player: playerId, evidence: amount)
                            playerNames.append(p.realName)
                        } else {
                            print("couldn't find player \(playerId)")
                            return
                        }
                    }
                    
                    DispatchQueue.main.async {
                        self.setNoLongerIntercepting(target, true)
                        print("intercept on \(target.realName) successful")
                    }
                } catch {}
            case 201:
                print("intercept created")
            case 204:
                self.interceptTimer.invalidate()
                DispatchQueue.main.async {
                    self.setNoLongerIntercepting(target, false)
                    print("no exchange happened for \(statusCode)")
                }
            case 206:
                print("INTERCEPT waiting for response, keep polling")
            case 400:
                self.interceptTimer.invalidate()
                DispatchQueue.main.async {
                    self.setNoLongerIntercepting(target, false)
                    print("no exchange happened for \(statusCode)")
                }
            case 404:
                self.interceptTimer.invalidate()
                DispatchQueue.main.async {
                    self.setNoLongerIntercepting(target, false)
                    print("already intercepting someone")
                }
            default:
                print("something weird has happened in intercept with status code \(statusCode)")
            }
        }.resume()
    }
    
    func setCurrentlyIntercepting(_ player: Player) {
        //player.currentlyIntercepting = true
        let p = self.gameState.getPlayerById(player.id)
        p!.exchangeDisabled = true
        p!.interceptRequested = true
        for p in self.gameState.allPlayers {
            p.interceptDisabled = true
        }
    }
    
    func setNoLongerIntercepting(_ player: Player, _ success: Bool) {
        var p = self.gameState.getPlayerById(player.id)
        p!.interceptRequested = false
        p!.interactionResult = success ? 1 : 2
        enableEnableableButtons()
        self.playerTableView.reloadData()
        self.playerTableView.layoutIfNeeded()
        p = self.gameState.getPlayerById(player.id)!
        p!.interactionResult = 0
    }
    
    func enableEnableableButtons() {
        // work out if an exchange or intercept is currently in progress
        var exchangeCurrentlyPending = false
        var interceptCurrentlyPending = false
        for player in self.gameState.allPlayers {
            if (player.exchangeRequested) {
                exchangeCurrentlyPending = true
            }
            if (player.interceptRequested) {
                interceptCurrentlyPending = true
            }
        }
        // only enable intercepts if not doing one
        if (!interceptCurrentlyPending) {
            for player in self.gameState.allPlayers {
                if (!player.exchangeRequested && !player.interceptRequested) {
                    player.interceptDisabled = false
                }
            }
        }
        // only enable exchanges if not doing one
        if (!exchangeCurrentlyPending) {
            for player in self.gameState.allPlayers {
                if (!player.exchangeRequested && !player.interceptRequested) {
                    player.exchangeDisabled = false
                }
            }
        }
    }
    
    // MARK: Expose
    
    @objc func exposeButtonAction(sender: UIButton!) {
        self.ungreyOutAllCells()
        let target: Int = sender.tag
        let player : Player = gameState.getPlayerById(target)!
        print("expose button tapped for player \(player.realName)")
        
        // attempt to expose far away person
        if (player.nearby == false) {
            DispatchQueue.main.async {
                print("player wasn't nearby")
            }
            return
        }
        // attempt to expose with insufficient intel
        if (player.evidence < 100) {
            DispatchQueue.main.async {
                self.logVC.setMessage(exposeFailedWithInsufficientIntel: player.realName)
                self.showLog()
            }
            return
        }
        // attempt to expose wrong person
        if (player.codeName != self.gameState.currentTarget!.codeName) {
            DispatchQueue.main.async {
                self.logVC.setMessage(exposeFailedWithWrongPerson: player.realName)
                self.showLog()
                print("not your target")
            }
            return
        }
        
        
        // create data
        let data: [String: Int] = [
            "player_id": self.gameState.player!.id,
            "target_id": player.id
        ]
        
        let request = ServerUtils.post(to: "/expose", with: data)
        
        URLSession.shared.dataTask(with: request) { (data, response, error) in
            
            guard let httpResponse = response as? HTTPURLResponse else {
                self.logVC.setMessage(networkError: true)
                self.showLog()
                return
            }
            
            let statusCode: Int = httpResponse.statusCode
            
            print("taken down status code " + String(statusCode))
            
            if (statusCode == 200) {
                
                guard let responseData = data else { return }
                do {
                    
                    let bodyJson = try JSONSerialization.jsonObject(with: responseData, options: [])
                    
                    guard let bodyDict = bodyJson as? [String: Any] else { return }
                    guard let reputation = bodyDict["reputation"] as? Int else { return }
                    self.gameState!.points += reputation
                    let p = self.gameState.getPlayerById(player.id)
                    p!.evidence = 0
                    DispatchQueue.main.async {
                        self.pointsValue.text = String(self.gameState.points) + " rep /"
                        print("expose successful")
                        self.alertVC.setMessage(successfulExpose: true, reputation: reputation)
                        self.showAlert()
                        self.playerTableView.reloadData()
                        self.startCheckingForHomeBeacon(withCallback: self.requestNewTarget)
                    }
                } catch {}
            } else {
                DispatchQueue.main.async {
                    // small popup here
                    print("take down failed\n\(String(describing: response))")
                }
            }
            }.resume()
    }
    
}
