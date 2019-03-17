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
        let interacteeId = sender.tag
        let player : Player = gameState.getPlayerById(sender.tag)!
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
        } else {
            DispatchQueue.main.async {
                self.alertVC.setMessage(message: "EXCHANGE_FAIL\n\nPlayer not nearby", tapToClose: true)
            }
        }
    }
    
    @objc func exchangeRequest() {
        let requestdata: [String:Any] = exchangeTimer.userInfo as! [String:Any]
        let request = ServerUtils.post(to: "/exchangeRequest", with: requestdata)
        
        URLSession.shared.dataTask(with: request) { (data, response, error) in
            
            guard let httpResponse = response as? HTTPURLResponse else { return }
            
//            let statusCode: Int = httpResponse.statusCode
            let statusCode = 201
            print("exchange code " + String(statusCode))
            let responderName = self.gameState.getPlayerById(requestdata["responder_id"] as! Int)!.realName
            switch statusCode {
            case 201: // created
                
                DispatchQueue.main.async {
                    self.logVC.setMesssage(exchangeRequestedWith: responderName)
                    self.showLog()
                }
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
                        players.append(self.gameState.getPlayerById(playerId)!.realName)
                        let amount: Int = e["amount"] as! Int
                        self.gameState.incrementEvidence(player: playerId, evidence: amount)
                    }
                    
                    DispatchQueue.main.async {
                        self.logVC.setMessage(exchangeSuccessfulWithPlayer: responderName, evidence: players)
                        self.showLog()
                        print("Exchange accepted, put small popup here")
                    }
                } catch {}
            case 204: // rejected
                self.exchangeTimer.invalidate()
                DispatchQueue.main.async {
                    print("Exchange rejected, put small popup here")
                }
            case 400, 404: // error
                self.exchangeTimer.invalidate()
                print("You did a bad exchange")
            case 408: // timeout
                self.exchangeTimer.invalidate()
                self.exchangeTimer.invalidate()
                DispatchQueue.main.async {
                    print("Exchange timed out, put small popup here")
                }
            default:
                print("/exchangeRequest unexpected \(statusCode)")
            }
            }.resume()
    }
    
    // MARK: Takedown
    
    @objc func exposeButtonAction(sender: UIButton!) {
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
                print("insufficient intel to expose")
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
        
        DispatchQueue.main.async {
            print("Initiating expose")        }
        
        // create data
        let data: [String: Int] = [
            "player_id": self.gameState.player!.id,
            "target_id": self.gameState.allPlayers[target].id
        ]
        print("taking down with data:\n\t\(data)\n")
        
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
                    
                    DispatchQueue.main.async {
                        // big popup
                        print("expose successful")
                        
//                        self.alertVC.setMessage(successfulExpose: true, reputation: reputation)
//                        self.showAlert()
                        self.playerTableView.reloadData()
                        self.startCheckingForHomeBeacon(withCallback: self.requestNewTarget)
                        //self.gameState.unhideAll()
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
