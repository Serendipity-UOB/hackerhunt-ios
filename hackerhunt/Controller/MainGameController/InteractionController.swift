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
        let player : Player = gameState.getPlayerById(sender.tag)!
        player.exchangeRequested = true
        DispatchQueue.main.async {
            self.playerTableView.reloadData()
        }

        print("exchange button tapped for player \(player.realName)")
        
        if (gameState.playerIsNearby(interacteeId)) {
            let validContacts: [[String: Int]] = self.gameState.allPlayers
                .filter({ $0.evidence > 0.0 })
                .map({ return ["contact_id": $0.id] })
            
            let data: [String:Any] = [
                "requester_id": self.gameState.player!.id,
                "responder_id": interacteeId,
                "contact_ids": validContacts
            ]
            
            // send request
            exchangeTimer.invalidate()
            exchangeTimer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(MainGameViewController.exchangeRequest), userInfo: data, repeats: true)
            exchangeTimer.fire()
        }
    }
    
    @objc func exchangeRequest() {
        let requestdata: [String:Any] = exchangeTimer.userInfo as! [String:Any]
        let player = self.gameState.getPlayerById(requestdata["responder_id"]! as! Int)
        let request = ServerUtils.post(to: "/exchangeRequest", with: requestdata)
        
        URLSession.shared.dataTask(with: request) { (data, response, error) in
            
            guard let httpResponse = response as? HTTPURLResponse else { return }
            
            let statusCode: Int = httpResponse.statusCode
            print("exchange code " + String(statusCode))
            let responderName = self.gameState.getPlayerById(requestdata["responder_id"] as! Int)!.realName
            switch statusCode {
            case 201: // created
                DispatchQueue.main.async {
                    self.logVC.setMesssage(exchangeRequestedWith: responderName)
                    self.showLog()
                    print("Exchange requested")
                }
            case 202: // accepted
                guard let responseData = data else { return }
                do {
                    self.exchangeTimer.invalidate()
                    player?.exchangeRequested = false
                    
                    let bodyJson = try JSONSerialization.jsonObject(with: responseData, options: [])
                    
                    guard let bodyDict = bodyJson as? [String: Any] else { return }
                    guard let evidence = bodyDict["evidence"] as? [[String:Any]] else {
                        print("evidence missing")
                        return
                    }
                    var players: [String] = []
                    for e in evidence {
                        let playerId: Int = e["player_id"] as! Int
                        players.append(self.gameState.getPlayerById(playerId)!.realName)
                        let amount: Int = e["amount"] as! Int
                        self.gameState.incrementEvidence(player: playerId, evidence: amount)
                    }
                    
                    DispatchQueue.main.async {
                        self.playerTableView.reloadData()
                        self.logVC.setMessage(exchangeSuccessfulWithPlayer: responderName, evidence: players)
                        self.showLog()
                        print("Exchange accepted")
                    }
                } catch {}
            case 204: // rejected
                self.exchangeTimer.invalidate()
                player?.exchangeRequested = false
                DispatchQueue.main.async {
                    self.playerTableView.reloadData()
                    self.logVC.setMessage(exchangeRejected: responderName)
                    self.showLog()
                    print("Exchange rejected, put small popup here")
                }
            case 206:
                print("keep polling")
            case 400, 404: // error
                self.exchangeTimer.invalidate()
                player?.exchangeRequested = false
                self.playerTableView.reloadData()
                print("You did a bad exchange")
            case 408: // timeout
                self.exchangeTimer.invalidate()
                player?.exchangeRequested = false
                DispatchQueue.main.async {
                    self.playerTableView.reloadData()
                    self.logVC.setMessage(exchangeTimeout: responderName)
                    self.showLog()
                    print("Exchange timed out, put small popup here")
                }
            default:
                print("/exchangeRequest unexpected \(statusCode)")
            }
            }.resume()
    }
    
    
    func exchangeResponse(_ requesterId: Int) {
        let validContacts: [[String: Int]] = self.gameState.allPlayers
            .filter({ $0.evidence > 0.0 })
            .map({ return ["contact_id": $0.id] })
        
        let data: [String:Any] = [
            "responder_id": self.gameState.player!.id,
            "requester_id": requesterId,
            "contact_ids": validContacts
        ]
        
        self.exchangeRequestTimer.invalidate()
        self.exchangeRequestTimer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(MainGameViewController.exchangeResponseRequest), userInfo: data, repeats: true)
        self.exchangeRequestTimer.fire()
    }
    
    @objc func exchangeResponseRequest() {
        var requestdata: [String:Any] = exchangeRequestTimer.userInfo as! [String:Any]
        requestdata["response"] = self.exchangeResponse
        let request = ServerUtils.post(to: "/exchangeResponse", with: requestdata)
        
        URLSession.shared.dataTask(with: request) { (data, response, error) in
            
            guard let httpResponse = response as? HTTPURLResponse else { return }
            
            let statusCode: Int = httpResponse.statusCode
            
            switch statusCode {
            case 202:
                print("exchange request accepted")
                self.exchangeRequestTimer.invalidate()
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
                    
                    for e in evidence {
                        let playerId: Int = e["player_id"] as! Int
                        let amount: Int = e["amount"] as! Int
                        self.gameState.incrementEvidence(player: playerId, evidence: amount)
                    }
                    
                    DispatchQueue.main.async {
                        self.playerTableView.reloadData()
                        self.hideExchangeRequested()
                    }
                } catch {}
            case 205:
                self.exchangeRequestTimer.invalidate()
                print("exchange request successfully rejected")
                DispatchQueue.main.async {
                    self.hideExchangeRequested()
                }
            case 206:
                print("keep polling")
                guard let responseData = data else { return }
                do {
                    let bodyJson = try JSONSerialization.jsonObject(with: responseData, options: [])
                    guard let bodyDict = bodyJson as? [String: Any] else {
                        print("something went wrong accessing 206 response data exchange request")
                        return
                    }
                    guard let timeRemaining = bodyDict["time_remaining"] as? String else {
                        print("time remaining missing in exchange response")
                        return
                    }
                    let seconds = calculateTimeRemaining(startTime: timeRemaining)
                    DispatchQueue.main.async {
                        self.exchangeRequestedRejectButton.setTitle("REJECT \(seconds)", for: .normal)
                    }
                    
                } catch {}
            case 400:
                self.exchangeRequestTimer.invalidate()
                print("something we did was wrong in exchange response")
            case 408:
                self.exchangeRequestTimer.invalidate()
                print("exchange response timed out")
                DispatchQueue.main.async {
                    self.hideExchangeRequested()
                }
            default:
                self.exchangeRequestTimer.invalidate()
                print("something went wrong in exchange response with code \(statusCode)")
            }
        }.resume()
    }
    
    
    // MARK: Intercept
    
    @objc func interceptButtonAction(sender: UIButton!) {
        self.ungreyOutAllCells()
        let player : Player = gameState.getPlayerById(sender.tag)!
        print("intercept button tapped for player \(player.realName)")
        
        let targetId = sender.tag
        
        if (gameState.playerIsNearby(targetId)) {
            
            let data: [String:Any] = [
                "player_id": self.gameState.player!.id,
                "target_id": targetId
            ]
            
            interceptTimer.invalidate()
            interceptTimer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(MainGameViewController.interceptRequest), userInfo: data, repeats: true)
            interceptTimer.fire()
        }
    }
    
    @objc func interceptRequest() {
        let requestdata: [String:Any] = interceptTimer.userInfo as! [String:Any]
        let request = ServerUtils.post(to: "/intercept", with: requestdata)
        
        let target = self.gameState.getPlayerById(requestdata["target_id"]! as! Int)!.realName
        
        URLSession.shared.dataTask(with: request) { (data, response, error) in
            
            guard let httpResponse = response as? HTTPURLResponse else { return }
            
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
                    
                    var players: [String] = []
                    for e in evidence {
                        let playerId: Int = e["player_id"] as! Int
                        players.append(self.gameState.getPlayerById(playerId)!.realName)
                        let amount: Int = e["amount"] as! Int
                        self.gameState.incrementEvidence(player: playerId, evidence: amount)
                    }
                    
                    DispatchQueue.main.async {
                        self.playerTableView.reloadData()
                        self.logVC.setMessage(interceptSuccessfulOn: target, withEvidenceOn: players)
                        self.showLog()
                        print("intercept successful")

                    }
                } catch {}
            case 201:
                DispatchQueue.main.async {
                    self.logVC.setMessage(interceptRequestedOn: target)
                    self.showLog()
                    print("intercept created")
                }
            case 204:
                self.interceptTimer.invalidate()
                DispatchQueue.main.async {
                    self.logVC.setMessage(interceptFailed: target)
                    self.showLog()
                    print("no exchange happened")
                }
            case 206:
                print("waiting for response, keep polling")
            case 400:
                self.interceptTimer.invalidate()
                DispatchQueue.main.async {
                    self.logVC.setMessage(interceptFailedOn: target)
                    self.showLog()
                    print("no exchange happened")
                }
            case 404:
                print("something unexpected went wrong in intercept request")
            default:
                print("something weird has happened in intercept with status code \(statusCode)")
            }
                
            
        }.resume()
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
                print("not your target")
            }
            return
        }
        
        
        // create data
        let data: [String: Int] = [
            "player_id": self.gameState.player!.id,
            "target_id": self.gameState.allPlayers[target].id
        ]
        
        let request = ServerUtils.post(to: "/expose", with: data)
        
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
                    self.gameState!.points += reputation
                    player.evidence = 0
                    DispatchQueue.main.async {
                        self.pointsValue.text = String(self.gameState.points) + " rep /"
                        print("expose successful")
                        self.alertVC.setMessage(successfulExpose: true, reputation: reputation)
                        self.showAlert()
                        self.playerTableView.reloadData()
                        self.startCheckingForHomeBeacon(withCallback: self.requestNewTarget)
                        self.takedown = false
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
