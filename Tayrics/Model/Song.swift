//
//  Song.swift
//  Tayrics
//
//  Created by Clarence Ji on 6/25/20.
//

import UIKit

struct Song: Codable, Hashable {
    
    enum CodingKeys: String, CodingKey {
        case trackNumber = "track-number"
        case name
        case length
        case appleMusicURL = "apple-music-url"
    }
    
    let trackNumber: Int
    let name: String
    let length: TimeInterval
    let appleMusicURL: String
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(trackNumber)
        hasher.combine(name)
        hasher.combine(length)
        hasher.combine(appleMusicURL)
    }
}
