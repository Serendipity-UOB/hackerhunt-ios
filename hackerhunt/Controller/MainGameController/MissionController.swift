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
    }
    
    @objc func missionUpdates() {
        let data: [String:Int] = [
            "player_id": (self.gameState.player?.id)!
        ]
        
        let request = ServerUtils.post(to: "/missionUpdate", with: data)
        
        URLSession.shared.dataTask(with: request) { (data, response, error) in
            
            guard let httpResponse = response as? HTTPURLResponse else { return }
            
            let statusCode: Int = httpResponse.statusCode
            
            switch statusCode {
            case 200:
                self.missionTimer.invalidate()
                guard let responsedata = data else { return }
                do {
                    let bodyJson = try JSONSerialization.jsonObject(with: responsedata, options: [])
                    
                    guard let bodyDict = bodyJson as? [String: Any] else { return }
                    guard let evidence = bodyDict["evidence"] as? [[String: Int]] else {
                        print("no evidence in mission success")
                        return
                    }
                    guard let description = bodyDict["success_description"] as? String else {
                        print("no description in mission success")
                        return
                    }
                    
                    for element in evidence {
                        self.gameState.incrementEvidence(player: element["player_id"]!, evidence: element["amount"]!)
                    }
                    DispatchQueue.main.async {
                        self.playerTableView.reloadData()
                        self.alertVC.setMessage(missionSuccess: true, missionString: description)
                        self.showAlert()
                    }
                    
                    
                } catch {}
            case 203:
                self.missionTimer.invalidate()
                guard let responsedata = data else { return }
                do {
                    let bodyJson = try JSONSerialization.jsonObject(with: responsedata, options: [])
                    
                    guard let bodyDict = bodyJson as? [String: Any] else { return }
                    guard let description = bodyDict["failure_description"] as? String else {
                        print("no description in mission success")
                        return
                    }
                    
                    DispatchQueue.main.async {
                        self.playerTableView.reloadData()
                        self.alertVC.setMessage(missionFailure: true, missionString: description)
                        self.showAlert()
                    }
                    
                    
                } catch {}
            case 206:
                print("time remaining for missions not yet implemented")
            case 400:
                print("mission something went wrong from client")
            default:
                print("mission updated received clienterror")  
            }
            }.resume()
    }
    
}
