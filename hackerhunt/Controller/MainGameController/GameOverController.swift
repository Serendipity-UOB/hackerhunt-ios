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
            
            guard let httpResponse = response as? HTTPURLResponse else { return }
            
            let statusCode: Int = httpResponse.statusCode
            
            if (statusCode == 200) {
                guard let responseData = data else { return }
                do {
                    let bodyJson = try JSONSerialization.jsonObject(with: responseData, options: [])
                    guard let bodyDict = bodyJson as? [String:[[String: Any]]] else { return }
                    guard let leaderboard : [[String: Any]] = bodyDict["leaderboard"] else {
                        print("leaderboard missing")
                        return
                    }
                    
                    self.gameState.assignScores(scoreList: leaderboard)
                    self.goToLeaderboard()
                } catch {}
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
