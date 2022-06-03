//
//  Card.swift
//  Milestone10
//
//  Created by Brian Coleman on 2022-06-02.
//

import Foundation

enum CardState {
    case front
    case back
    case matched
    case complete
}

class Card {
    var state: CardState = .back
    var backImage: String
    var frontImage: String
    
    init(frontImage: String, backImage: String) {
        self.frontImage = frontImage
        self.backImage = backImage
    }
}
