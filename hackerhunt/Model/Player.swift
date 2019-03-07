//
//  Player.swift
//  hackerhunt
//
//  Created by Louis Heath on 22/01/2019.
//  Copyright © 2019 Louis Heath. All rights reserved.
//

class Player {
    
    init(realName: String, codeName: String, id: Int) {
        self.realName = realName
        self.codeName = codeName
        self.id = id
    }
    
    var realName: String
    var codeName: String
    var id: Int
    
    var hide: Bool = false
    var nearby: Bool = false
    var intel: Float = 0.0
    var score: Int = 0
    
    
    func copy() -> Player {
        let copy = Player(realName: self.realName, codeName: self.codeName, id: self.id)
        copy.nearby = self.nearby
        copy.intel = self.intel
        copy.hide = self.hide
        return copy
    }
    
}
