//
//  GameState.swift
//  hackerhunt
//
//  Created by Louis Heath on 22/01/2019.
//  Copyright © 2019 Louis Heath. All rights reserved.
//

import Foundation
import KontaktSDK

class GameState {
    
    var player: Player?
    
    var nearbyBeacons: [CLBeacon]?
    var homeBeacon: String?

    var allPlayers: [Player]?
    var currentTarget: Player?
    
    var points: Int?
    var position: Int?
    
    func getNearestBeacon() -> String {
        if (nearbyBeacons!.count >= 1) {
            // return nearbyBeacons[0].name ??
            return "A"
        }
        return "A"
    }
    
    func incrementIntelFor(playerOne: Int, playerTwo: Int) {
        for player in allPlayers! {
            if (player.id == playerOne || player.id == playerTwo) {
                player.intel = min(player.intel + 0.2, 1.0)
            }
        }
    }
    
    func deleteHalfOfIntel() {
        for player in allPlayers! {
            let intel = (player.intel / 2.0)
            let remainder = intel.truncatingRemainder(dividingBy: 0.2)
            player.intel = intel - remainder
        }
    }
    
}
