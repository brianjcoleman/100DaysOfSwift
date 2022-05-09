//
//  Note.swift
//  Milestone7
//
//  Created by Brian Coleman on 2022-05-09.
//

import Foundation

class Note: Codable {
    var text: String
    var modificationDate: Date

    init(text: String, modificationDate: Date) {
        self.text = text
        self.modificationDate = modificationDate
    }
}
