//
//  Word.swift
//  Project5
//
//  Created by Brian Coleman on 2022-03-22.
//

import Foundation

class Level: NSObject, Codable {
    var word: String
    var usedWords: [String]
    
    init(word: String, usedWords: [String]) {
        self.word = word
        self.usedWords = usedWords
    }
}
