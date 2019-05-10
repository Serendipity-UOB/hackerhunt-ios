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
    
    var nearbyBeacons: [CLBeacon] = []
    var homeBeacon: String?

    var allPlayers = [Player]()
    var currentTarget: Player?
    
    var points: Int = 0
    var position: Int = 1 // everyone starts as first?
    
    var endTime : Int?
    var missionBeacon: String = ""
    
    init() {}
    
    func getNearestBeaconMajor() -> Int {
        for beacon in nearbyBeacons {
            if (beacon.rssi != 0) {
                return beacon.major.intValue
            }
        }
        if (nearbyBeacons.count > 0) {
            return nearbyBeacons[0].major.intValue
        } else {
            return 0
        }
    }
    
    func incrementEvidence(player: Int, evidence: Int) {
        for p in allPlayers {
            if (p.id == player) {
                p.evidence = min(p.evidence + Float(evidence), 100)
                let codeNameAlreadyDiscovered = p.codeNameDiscovered
                p.codeNameDiscovered = (p.evidence == 100 || codeNameAlreadyDiscovered) ? true : false
                if (!codeNameAlreadyDiscovered && p.codeNameDiscovered) {
                    sendDecipherCodename()
                }
                break
            }
        }
        
    }
    
    func sendDecipherCodename() {
        let request : URLRequest = ServerUtils.post(to: "/decipherCodename", with: ["player_id":player!.id])
        
        URLSession.shared.dataTask(with: request) { (data, response, error) in
            if let httpResponse = response as? HTTPURLResponse {
                let statusCode: Int = httpResponse.statusCode
                if statusCode != 200 {
                    print("failed /decipherCodename response \(statusCode)")
                }
            }}.resume()
        return
    }
    
    func deleteHalfOfIntel() {
        for player in allPlayers {
            let intel = (player.evidence / 2.0)
            player.evidence = intel.rounded()
//            let remainder = intel.truncatingRemainder(dividingBy: 0.2)
//            let rounded = round(remainder * 10)/10
//            player.evidence = intel
        }
    }
    
    func insertTestData() {
        self.player = Player(realName: "Louis", codeName: "King", id: 0)
        let newPlayers = [
            Player(realName: "Tilly", codeName: "Matilda", id: 1),
            Player(realName: "Tom", codeName: "Brickhead", id: 2),
            Player(realName: "Jack", codeName: "JackedJones", id: 3),
            Player(realName: "David", codeName: "Weab", id: 4),
            Player(realName: "Nuha", codeName: "Nunu", id: 5)
        ]
        newPlayers[0].nearby = true
        newPlayers[4].nearby = true
        newPlayers[0].evidence = 20
        newPlayers[2].evidence = 40
        newPlayers[3].evidence = 80
        newPlayers[4].evidence = 100
        self.allPlayers.append(contentsOf: newPlayers)
        prioritiseNearbyPlayers()
    }
    
    var sorting = false
    func prioritiseNearbyPlayers() {
        print("sorting")
        sorting = true
        self.allPlayers.sort { $0.nearby && !$1.nearby }
        sorting = false
        print("done sorting")
    }
    
    func getPlayerById(_ id: Int) -> Player? {
        while (sorting) {
            print("waiting for sort to end")
        }
        print("searching for player \(id)")
        for p in self.allPlayers {
            print("\t\(p.realName) has id \(p.id)")
            if (p.id == id) {
                return p
            }
        }
        print("Failed to find player with id \(id)\n")
        printAllPlayers()
        return nil
    }
    
    func createBeaconList() -> [[String:Any]] {
        var beacons_list : [[String:Any]] = []
        for beacon in nearbyBeacons {
                let temp: [String:Any] = [
                    "beacon_minor": beacon.minor,
                    "beacon_major": beacon.major,
                    "rssi": beacon.rssi
                ]
                beacons_list.append(temp)
        }
        return beacons_list
    }
    
    func isGameOver() -> Bool {
        if (endTime! - Int(now()) <= 0) {
            return true
        } else {
            return false
        }
    }
    
    func assignScores(scoreList: [[String: Any]]) {
        for player in scoreList {
            let id = player["player_id"] as! Int
            if (id != self.player!.id) {
                let p = getPlayerById(id)
                p!.score = player["score"] as! Int
                p!.position = player["position"] as! Int
            } else {
                // TODO score didn't exist here ?
                if let score : Int = player["score"] as? Int {
                    self.player!.score = score
                } else {
                    print("player \(id) score not found\n")
                }
                if let position : Int = player["position"] as? Int {
                    self.player!.position = position
                } else {
                    print("player \(id) position not found\n")
                }
            }
        }
    }
    
    func getPlayerByRealName(realName: String) -> Player? {
        for p in self.allPlayers {
            if (p.realName == realName) {
                return p
            }
        }
        return nil
    }
    
    func initialisePlayerList(allPlayers: [[String: Any]]) {
        // add players but yourself to allPlayers
        for player in allPlayers {
            let codeName: String = player["code_name"] as! String
            if (codeName != self.player!.codeName) {
                let realName: String = player["real_name"] as! String
                let id: Int = player["id"] as! Int
                let player: Player = Player(realName: realName, codeName: codeName, id: id)
                if (ServerUtils.testing) {
                    player.evidence = 90.0
                }
                self.allPlayers.append(player)
            }
        }
    }
    
    func setFirstTarget(_ firstTargetId: Int) -> Bool {
        for p in self.allPlayers {
            if p.id == firstTargetId {
                self.currentTarget = p
                return true
            }
        }
        return false
    }
    
    func playerIsNearby(_ id: Int) -> Bool {
        let player = getPlayerById(id)
        if let player = player {
            return player.nearby
        } else {
            return false
        }
    }
    
    func prepareLeaderboard() {
        self.allPlayers.append(self.player!)
        self.allPlayers.sort(by: { $0.position < $1.position })
    }
    
    func printAllPlayers() {
        print("printing all players")
        for p in self.allPlayers {
            print("\t\(p.realName) \(p.id)")
        }
    }
}
