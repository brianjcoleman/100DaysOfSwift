//
//  Picture.swift
//  Milestone4
//
//  Created by Brian Coleman on 2022-03-23.
//

import Foundation

class Picture: NSObject, Codable {
    var image = String()
    var caption = String()

    init(image: String, caption: String) {
        self.image = image
        self.caption = caption
    }
}
