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
    
}
