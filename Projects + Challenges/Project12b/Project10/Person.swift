//
//  Person.swift
//  Project10
//
//  Created by Brian Coleman on 2022-03-12.
//

import UIKit

class Person: NSObject, Codable {
    var name: String
    var image: String
    
    init(name: String, image: String) {
        self.name = name
        self.image = image
    }
}
