//
//  MediaService.swift
//  Tayrics
//
//  Created by Clarence Ji on 6/25/20.
//

import Foundation

struct MediaService {
    
    let albums: [Album]
    
    init() {
        
        guard
            let filePath = Bundle.main.url(forResource: "Tayrics-Data", withExtension: "json"),
            let data = try? Data(contentsOf: filePath),
            let albums = try? JSONDecoder().decode([Album].self, from: data)
        else {
            fatalError()
        }
        
        self.albums = albums
    }
}
