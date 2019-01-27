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
    var homeBeacon: HomeBeacon?

    var allPlayers = [Player]()
    var currentTarget: Player?
    
    var points: Int = 0
    var position: Int = 1 // everyone starts as first?
    
    var endTime : Int?
    var countdown : Int?
    
    init() {
//        insertTestData()
    }
    
    func getNearestBeacon() -> String {
        /*if (nearbyBeacons!.count >= 1) {
            // return nearbyBeacons[0].name ??
            return "A"
        }*/
        return "A"
    }
    
    func incrementIntelFor(playerOne: Int, playerTwo: Int) {
        for player in allPlayers {
            if (player.id == playerOne || player.id == playerTwo) {
                player.intel = min(player.intel + 0.2, 1.0)
            }
        }
    }
    
    func deleteHalfOfIntel() {
        for player in allPlayers {
            let intel = (player.intel / 2.0)
            let remainder = intel.truncatingRemainder(dividingBy: 0.2)
            player.intel = intel - remainder
        }
    }
    
    func insertTestData() {
        self.player = Player(realName: "Louis", hackerName: "King", id: 0)
        let newPlayers = [
            Player(realName: "Tilly", hackerName: "Matilda", id: 1),
            Player(realName: "Tom", hackerName: "Brickhead", id: 2),
            Player(realName: "Jack", hackerName: "JackedJones", id: 3),
            Player(realName: "David", hackerName: "Weab", id: 4),
            Player(realName: "Nuha", hackerName: "Nunu", id: 5)
        ]
        newPlayers[0].nearby = true
        newPlayers[4].nearby = true
        newPlayers[0].intel = 0.2
        newPlayers[2].intel = 0.4
        newPlayers[3].intel = 0.8
        newPlayers[4].intel = 1.0
        self.allPlayers.append(contentsOf: newPlayers)
        self.allPlayers = prioritiseNearbyPlayers()
    }
    
    func prioritiseNearbyPlayers() -> [Player] {
        var copy = self.allPlayers.map { $0.copy() }
        
        for i in 1..<copy.count {
            var j = i
            while j > 0 && copy[j - 1].nearby == false && copy[j].nearby == true {
                let tmp = copy[j]
                copy[j] = copy[j - 1]
                copy[j - 1] = tmp
                j -= 1
            }
        }
        
        return copy
    }
    
    func getPlayerById(_ id: Int) -> Player? {
        for p in self.allPlayers {
            if (p.id == id) {
                return p
            }
        }
        return nil
    }
}
