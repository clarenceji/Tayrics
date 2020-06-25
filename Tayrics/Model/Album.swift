//
//  Album.swift
//  Tayrics
//
//  Created by Clarence Ji on 6/25/20.
//

import Foundation
import UIKit

struct Album: Codable, Hashable {
    
    enum CodingKeys: String, CodingKey {
        case order = "album-number"
        case name = "album-title"
        case coverImageName = "album-cover-name"
        case songs
    }
    
    let order: Int
    let name: String
    let coverImageName: String
    let songs: [Song]
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(order)
        hasher.combine(name)
        hasher.combine(coverImageName)
        hasher.combine(songs)
    }
}
