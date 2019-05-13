//
//  CardState.swift
//  hackerhunt
//
//  Created by Louis Heath on 22/01/2019.
//  Copyright © 2019 Louis Heath. All rights reserved.
//

class CardState {
    
    init() {}
    
    init(isGreyedOut: Bool) {
        self.isGreyedOut = isGreyedOut
    }
    
    var isGreyedOut: Bool = false
    var buttonsEnabled: Bool = false
}
