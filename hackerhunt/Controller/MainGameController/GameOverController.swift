//
//  GameOverController.swift
//  hackerhunt
//
//  Created by Thomas Walker on 12/03/2019.
//  Copyright © 2019 Louis Heath. All rights reserved.
//

import Foundation
import UIKit

extension MainGameViewController {
    
    func gameOver() {
        updatesTimer.invalidate()
        countdownTimer.invalidate()
        // TODO check if we are currently interacting and clean up
        exchangeTimer.invalidate()
        homeBeaconTimer.invalidate()
        missionTimer.invalidate()
        let request = ServerUtils.get(from: "/endInfo")
        
        URLSession.shared.dataTask(with: request) { (data, response, error) in
            
            if (error != nil) {
                DispatchQueue.main.async {
                    self.logVC.setMessage(networkError: "end info")
                    self.showLog()
                }
                return
            }
            
            guard let httpResponse = response as? HTTPURLResponse else {
                return
            }
            
            let statusCode: Int = httpResponse.statusCode
            
            if (statusCode == 200) {
                print("/endInfo 200")
                guard let responseData = data else {
                    print("Error: couldn't parse responseData /endInfo")
                    return
                }
                do {
                    let bodyJson = try JSONSerialization.jsonObject(with: responseData, options: [])
                    guard let bodyDict = bodyJson as? [String:[[String: Any]]] else {
                        print("Error: couldn't parse /endInfo body json")
                        return
                    }
                    guard let leaderboard : [[String: Any]] = bodyDict["leaderboard"] else {
                        print("Error: leaderboard missing from /endInfo")
                        return
                    }
                    self.gameState.assignScores(scoreList: leaderboard)
                    DispatchQueue.main.async {
                        self.goToLeaderboard()
                    }
                } catch {}
            } else {
                print("/endInfo \(statusCode): Unexpected response")
            }
            }.resume()
    }
    
    // MARK: leaderboard
    
    func goToLeaderboard() {
        self.performSegue(withIdentifier:"transitionToLeaderboard", sender:self)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let leaderboardViewController = segue.destination as? LeaderboardViewController {
            self.gameState.prepareLeaderboard()
            leaderboardViewController.gameState = gameState
        }
    }
    
}
