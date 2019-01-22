//
//  Player.swift
//  hackerhunt
//
//  Created by Louis Heath on 22/01/2019.
//  Copyright © 2019 Louis Heath. All rights reserved.
//

class Player {
    
    init(realName: String, hackerName: String, id: Int) {
        self.realName = realName
        self.hackerName = hackerName
        self.id = id
    }
    
    init(hackerName: String, id: Int) {
        self.hackerName = hackerName
        self.id = id
        self.nearby = false
        self.intel = 0.0
    }
    
    var realName: String?
    var hackerName: String?
    var id: Int?
    
    var nearby: Bool?
    var intel: Float?
    
}
