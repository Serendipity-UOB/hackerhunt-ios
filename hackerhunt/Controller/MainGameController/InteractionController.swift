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
            }
            self.reloadTable()
            
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
            
            if (error != nil) {
                DispatchQueue.main.async {
                    self.logVC.setMessage(networkError: "exchange request")
                    self.showLog()
                }
                return
            }
            
            guard let httpResponse = response as? HTTPURLResponse else {
                return
            }
            
            let statusCode: Int = httpResponse.statusCode
            
            switch statusCode {
            case 201: // created
                print("/exchangeRequest 201: Exchange requested")
            case 202: // accepted
                print("/exchangeRequest 202: Exchange accepted")
                guard let responseData = data else { return }
                do {
                    self.exchangeTimer.invalidate()
                    
                    let bodyJson = try JSONSerialization.jsonObject(with: responseData, options: [])
                    
                    guard let bodyDict = bodyJson as? [String: Any] else {
                        print("Error: /exchangeRequest couldn't parse bodyJson 202")
                        return
                    }
                    guard let evidence = bodyDict["evidence"] as? [[String:Any]] else {
                        print("Error: evidence missing")
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
                            print("Error: /exchangeRequest couldn't find player \(playerId)")
                            return
                        }
                    }
                    
                    DispatchQueue.main.async {
                        self.setNoLongerExchanging(with: player, true)
                    }
                } catch {}
            case 204: // rejected
                print("/exchangeRequest 204: Exchange rejected")
                self.exchangeTimer.invalidate()
                DispatchQueue.main.async {
                    self.setNoLongerExchanging(with: player, false)
                }
            case 206:
                self.reloadTable()
                print("/exchangeRequest 206: Keep polling")
            case 400: // error
                self.exchangeTimer.invalidate()
                
                DispatchQueue.main.async {
                    self.setNoLongerExchanging(with: player, false)
                }
                print("/exchangeRequest 400: You did a bad exchange")
            case 404: // exchange already pending
                self.exchangeTimer.invalidate()
                
                DispatchQueue.main.async {
                    self.setNoLongerExchanging(with: player, false)
                }
                print("/exchangeRequest 404: Exchange already pending")
            case 408: // timeout
                self.exchangeTimer.invalidate()
                DispatchQueue.main.async {
                    self.setNoLongerExchanging(with: player, false)
                    print("/exchangeRequest 408: Exchange timed out")
                }
            default:
                self.exchangeTimer.invalidate()
                print("/exchangeRequest \(statusCode): Unexpected response")
                DispatchQueue.main.async {
                    self.setNoLongerExchanging(with: player, false)
                }
            }
        }.resume()
    }
    
    func setCurrentlyExchanging(with player: Player) {
        player.exchangeRequested = true
        player.interceptDisabled = true
        for p in self.gameState.allPlayers {
            p.exchangeDisabled = true
        }
    }
    
    func setNoLongerExchanging(with player: Player, _ success: Bool) {
        player.exchangeRequested = false
        player.interactionResult = success ? 1 : 2
        enableEnableableButtons()
        self.reloadTableSync()
        self.playerTableView.layoutIfNeeded()
        player.interactionResult = 0
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
            
            if (error != nil) {
                DispatchQueue.main.async {
                    self.logVC.setMessage(networkError: "exchange response")
                    self.showLog()
                }
                return
            }
            
            guard let httpResponse = response as? HTTPURLResponse else {
                return
            }
            
            let statusCode: Int = httpResponse.statusCode
            
            switch statusCode {
            case 202:
                print("/exchangeResponse 202: Exchange request accepted")
                self.exchangeRequestTimer.invalidate()
                self.exchangeResponse = 0
                guard let responseData = data else { return }
                do {
                    let bodyJson = try JSONSerialization.jsonObject(with: responseData, options: [])
                    guard let bodyDict = bodyJson as? [String: Any] else {
                        print("Error: something went wrong accessing 202 response data exchange request")
                        return
                    }
                    guard let evidence = bodyDict["evidence"] as? [[String:Any]] else {
                        print("Error: evidence missing for exchange request")
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
                            print("Error: couldn't find player \(playerId)")
                            return
                        }
                    }
                    
                    DispatchQueue.main.async {
                        self.hideExchangeRequested()
                    }
                    self.reloadTable()
                } catch {}
            case 205:
                print("/exchangeResponse 205: Request rejected")
                self.exchangeRequestTimer.invalidate()
                self.exchangeResponse = 0
                DispatchQueue.main.async {
                    self.hideExchangeRequested()
                }
            case 206:
                print("/exchangeResponse 206: Keep polling")
                guard let responseData = data else { return }
                do {
                    let bodyJson = try JSONSerialization.jsonObject(with: responseData, options: [])
                    guard let bodyDict = bodyJson as? [String: Any] else {
                        print("Error: something went wrong accessing 206 response data exchange request")
                        return
                    }
                    guard let timeRemaining = bodyDict["time_remaining"] as? Int else {
                        print("Error: time remaining missing in exchange response")
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
                print("/exchangeResponse 400: Bad request")
                DispatchQueue.main.async {
                    self.hideExchangeRequested()
                }
            case 408:
                self.exchangeRequestTimer.invalidate()
                self.exchangeResponse = 0
                print("/exchangeResponse 408: Exchange response timed out")
                DispatchQueue.main.async {
                    self.hideExchangeRequested()
                }
            default:
                self.exchangeRequestTimer.invalidate()
                self.exchangeResponse = 0
                print("/exchangeResponse \(statusCode): Unexpected response")
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
        
        if (!gameState.playerIsNearby(targetId)) {
            print("player not nearby")
            return
        }
        
        DispatchQueue.main.async {
            self.setCurrentlyIntercepting(player)
        }
        self.reloadTable()
        
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
        //print("\tintercept target \(requestdata["target_id"] ?? "??")")
        
        let request = ServerUtils.post(to: "/intercept", with: requestdata)
        
        let target = self.gameState.getPlayerById(requestdata["target_id"]! as! Int)!
        
        URLSession.shared.dataTask(with: request) { (data, response, error) in
            
            if (error != nil) {
                DispatchQueue.main.async {
                    self.logVC.setMessage(networkError: "intercept")
                    self.showLog()
                }
                return
            }
            
            guard let httpResponse = response as? HTTPURLResponse else {
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
                        print("Error: something went wrong accessing 200 response data intercept")
                        return
                    }
                    guard let evidence = bodyDict["evidence"] as? [[String:Any]] else {
                        print("Error: evidence missing for intercept")
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
                            print("Error: couldn't find player \(playerId)")
                            return
                        }
                    }
                    
                    DispatchQueue.main.async {
                        self.setNoLongerIntercepting(target, true)
                        print("/intercept 200: Intercept on \(target.realName) successful")
                    }
                } catch {}
            case 201:
                print("/intercept 201: Intercept created")
            case 204:
                print("/intercept 204: Intercept fail")
                self.interceptTimer.invalidate()
                DispatchQueue.main.async {
                    self.setNoLongerIntercepting(target, false)
                }
            case 206:
                print("/intercept 206: Keep polling")
            case 400:
                print("/intercept 400: Intercept fail")
                self.interceptTimer.invalidate()
                DispatchQueue.main.async {
                    self.setNoLongerIntercepting(target, false)
                }
            case 404:
                print("/intercept 404: Already intercepting someone")
                self.interceptTimer.invalidate()
                DispatchQueue.main.async {
                    self.setNoLongerIntercepting(target, false)
                }
            default:
                print("/intercept \(statusCode): Unexpected response")
            }
        }.resume()
    }
    
    func setCurrentlyIntercepting(_ player: Player) {
        player.exchangeDisabled = true
        player.interceptRequested = true
        for p in self.gameState.allPlayers {
            p.interceptDisabled = true
        }
    }
    
    func setNoLongerIntercepting(_ player: Player, _ success: Bool) {
        player.interceptRequested = false
        player.interactionResult = success ? 1 : 2
        enableEnableableButtons()
        self.reloadTableSync()
        self.playerTableView.layoutIfNeeded()
        player.interactionResult = 0
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
        
        // attempt to expose far away person
        if (player.nearby == false) {
            print("Expose error: player wasn't nearby")
            return
        }
        // attempt to expose with insufficient intel
        if (player.evidence < 100) {
            print("Expose error: insufficient evidence")
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
                print("Expose error: not your target")
            }
            return
        }
        
        // create data
        let data: [String: Int] = [
            "player_id": self.gameState.player!.id,
            "target_id": player.id
        ]
        
        print("exposing \(player.realName) with id \(data["target_id"] ?? -1)\n\tbutton tag used \(target). Own id \(data["player_id"] ?? -1)")
        
        let request = ServerUtils.post(to: "/expose", with: data)
        
        URLSession.shared.dataTask(with: request) { (data, response, error) in
            
            if (error != nil) {
                DispatchQueue.main.async {
                    self.logVC.setMessage(networkError: "expose")
                    self.showLog()
                }
                return
            }
            
            guard let httpResponse = response as? HTTPURLResponse else {
                print("Error: /expose could not parse http response")
                return
            }
            
            let statusCode: Int = httpResponse.statusCode
            
            if (statusCode == 200) {
                print("/expose 200: Success")
                guard let responseData = data else {
                    print("Error: /expose could not parse response data")
                    return
                }
                do {
                    let bodyJson = try JSONSerialization.jsonObject(with: responseData, options: [])
                    
                    guard let bodyDict = bodyJson as? [String: Any] else {
                        print("Error: /expose could not parse body json")
                        return
                    }
                    guard let reputation = bodyDict["reputation"] as? Int else {
                        print("Error: /expose could not parse reputation")
                        return
                    }
                    self.gameState!.points += reputation
                    let p = self.gameState.getPlayerById(player.id)
                    p!.evidence = 0
                    DispatchQueue.main.async {
                        self.pointsValue.text = String(self.gameState.points) + " rep /"
                        self.alertVC.setMessage(successfulExpose: true, reputation: reputation)
                        self.showAlert()
                        self.startCheckingForHomeBeacon(withCallback: self.requestNewTarget)
                    }
                    self.reloadTable()
                } catch {
                    print("Error: /expose do/catch block")
                }
            } else {
                print("/expose \(statusCode): Unexpected response")
            }
            }.resume()
    }
    
}
