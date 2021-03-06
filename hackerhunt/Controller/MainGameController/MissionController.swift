//
//  MissionController.swift
//  hackerhunt
//
//  Created by Thomas Walker on 12/03/2019.
//  Copyright © 2019 Louis Heath. All rights reserved.
//

import Foundation

extension MainGameViewController {
    
    func startMissionUpdates() {
        self.missionTimer.invalidate()
        missionTimer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(MainGameViewController.missionUpdates), userInfo: nil, repeats: true)
        missionTimer.tolerance = 0.4
    }
    
    @objc func missionUpdates() {
        let data: [String:Int] = [
            "player_id": (self.gameState.player?.id)!
        ]
        
        let request = ServerUtils.post(to: "/missionUpdate", with: data)
        
        URLSession.shared.dataTask(with: request) { (data, response, error) in
            
            if (error != nil) {
                DispatchQueue.main.async {
                    self.logVC.setMessage(networkError: "mission update")
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
                print("/missionUpdate 200: Mission success")
                self.missionTimer.invalidate()
                self.onMission = false
                guard let responsedata = data else { return }
                do {
                    let bodyJson = try JSONSerialization.jsonObject(with: responsedata, options: [])
                    
                    guard let bodyDict = bodyJson as? [String: Any] else { return }
                    guard let evidence = bodyDict["evidence"] as? [[String: Int]] else {
                        print("Error: no evidence in mission success")
                        return
                    }
                    guard let description = bodyDict["success_description"] as? String else {
                        print("Error: no description in mission success")
                        return
                    }
                    
                    for element in evidence {
                        self.gameState.incrementEvidence(player: element["player_id"]!, evidence: element["amount"]!)
                    }
                    DispatchQueue.main.async {
                        self.alertVC.setMessage(missionSuccess: true, missionString: description)
                        self.showAlert()
                    }
                    self.reloadTable()
                } catch {}
            case 203:
                print("/missionUpdate 203: Mission failed")
                self.missionTimer.invalidate()
                self.onMission = false
                guard let responsedata = data else { return }
                do {
                    let bodyJson = try JSONSerialization.jsonObject(with: responsedata, options: [])
                    
                    guard let bodyDict = bodyJson as? [String: Any] else { return }
                    guard let description = bodyDict["failure_description"] as? String else {
                        print("Error: no description in mission success")
                        return
                    }
                    
                    DispatchQueue.main.async {
                        self.alertVC.setMessage(missionFailure: true, missionString: description)
                        self.showAlert()
                    }
                    self.reloadTable()
                } catch {}
            case 204:
                print("/missionUpdate 204: You are on your start mission")
            case 205:
                print("/missionUpdate 205: Mission cancelled due to target takedown")
                self.missionTimer.invalidate()
                self.onMission = false
                DispatchQueue.main.async {
                    self.alertVC.removeAnimate()
                }
            case 206:
                guard let responsedata = data else { return }
                do {
                    let bodyJson = try JSONSerialization.jsonObject(with: responsedata, options: [])
                    
                    guard let bodyDict = bodyJson as? [String: Any] else { return }
                    guard let timeRemaining = bodyDict["time_remaining"] as? Int else {
                        print("Error: time remaining failed in mission update")
                        return
                    }
                    
                    DispatchQueue.main.async {
                        self.alertVC.updateCountdown(timeRemaining)
                    }
                } catch {}
                // TODO decrement timer
            case 400:
                self.missionTimer.invalidate()
                self.onMission = false
                print("/missionUpdate 400: Bad request")
            default:
                print("/missionUpdate \(statusCode): Unexpected response")
            }
        }.resume()
    }
    
}
