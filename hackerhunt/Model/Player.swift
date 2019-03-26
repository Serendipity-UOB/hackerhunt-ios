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
    
    var nearby: Bool = false
    var evidence: Float = 0.0
    var score: Int = 0
    var position: Int = 0
    var codeNameDiscovered: Bool = false
    var exchangeRequested: Bool = false
    var position: Int = 0
    
    func copy() -> Player {
        let copy = Player(realName: self.realName, codeName: self.codeName, id: self.id)
        copy.nearby = self.nearby
        copy.evidence = self.evidence
        copy.exchangeRequested = self.exchangeRequested
        copy.codeNameDiscovered = self.codeNameDiscovered
        copy.position = self.position
        return copy
    }
    
}
