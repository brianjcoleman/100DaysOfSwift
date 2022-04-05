//
//  Country.swift
//  Milestone5
//
//  Created by Brian Coleman on 2022-04-05.
//

import Foundation

struct Countries: Codable {
    var results: [Country]
}

struct Country: Codable {
    var name: String
    var capital: String?
    var population: Int
    var languages: [[String: String]]
    var currency: String
    var area : Int
    
    enum CodingKeys: String, CodingKey {
        case name = "country"
        case capital = "capital"
        case population = "population"
        case languages = "languages"
        case currency = "currency"
        case area = "area (sq mi)"
    }
}
