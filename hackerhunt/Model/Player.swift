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
    var zone: Int = 0
    var evidence: Float = 0.0
    var score: Int = 0
    var codeNameDiscovered: Bool = false
    var exchangeRequested: Bool = false
    var interceptRequested: Bool = false
    var interactionResult: Int = 0 // 0 = no result, 1 = success, 2 = failure
    var position: Int = 0
    var interceptDisabled: Bool = false
    var exchangeDisabled: Bool = false
    
    func copy() -> Player {
        let copy = Player(realName: self.realName, codeName: self.codeName, id: self.id)
        copy.nearby = self.nearby
        copy.zone = self.zone
        copy.evidence = self.evidence
        copy.codeNameDiscovered = self.codeNameDiscovered
        copy.exchangeRequested = self.exchangeRequested
        copy.interceptRequested = self.interceptRequested
        copy.interactionResult = self.interactionResult
        copy.position = self.position
        copy.interceptDisabled = self.interceptDisabled
        copy.exchangeDisabled = self.exchangeDisabled
        return copy
    }
    
}
