//
//  api.swift
//  diamond
//
//  Created by Denys Smirnov on 06/11/2022.
//

import Foundation

struct Podcast: Codable {
    var id: String
    var author: String
    var name: String
    var n_chuncks: Int
    var duration: Int
}

class API {
    let url: URL
    
    init(url: URL) {
        self.url = url
    }
    
    func downloadFull(id: String, callback: @escaping (URL) -> Void) {
        let destinationUrl =  FileManager.default
            .urls(for: .documentDirectory, in: .userDomainMask).first!
            .appendingPathComponent(UUID().uuidString)
        
        let audioURL = URL(string: "/podcast/\(id)/data", relativeTo: self.url)!
        
        let task = URLSession.shared.downloadTask(with: audioURL) { (location, response, error) in
            guard let location = location else {
                return
            }
            
            try! FileManager.default.moveItem(at: location ,to : destinationUrl)
            callback(destinationUrl)
        }

        task.resume()
    }

    func downloadChunk(id: String, callback: ()) {
        
    }
}

extension API {
    static var shared = API(url: URL(string: "https://8ec4-35-228-169-29.eu.ngrok.io")!)
}
