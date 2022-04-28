//
//  UserScript.swift
//  Extension
//
//  Created by Brian Coleman on 2022-04-28.
//

import Foundation

class UserScript: Codable {
    var name: String
    var script: String
    
    init(name: String, script: String) {
        self.name = name
        self.script = script
    }
}
