//
//  api.swift
//  diamond
//
//  Created by Denys Smirnov on 06/11/2022.
//

import Foundation
import Gzip

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
    
    func getPodcasts(callback: @escaping ([Podcast]) -> Void) {
        let url = URL(string: "/podcasts", relativeTo: self.url)!
        URLSession.shared.dataTask(with: url) { (data, response, error) in
            let podcasts = try! JSONDecoder().decode([Podcast].self, from: data!)
            callback(podcasts)
        }.resume()
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

    func downloadChunk(id: String, index: Int, callback: @escaping (Data) -> Void) {
        let audioURL = URL(string: "/podcast/\(id)/bin-gz/\(index)", relativeTo: self.url)!
        
        let task = URLSession.shared.downloadTask(with: audioURL) { (location, response, error) in
            guard let location = location else {
                return
            }
            let data = try! Data(contentsOf: location)
            callback(try! data.gunzipped())
        }

        task.resume()
    }
}

extension API {
    static var shared = API(url: URL(string: "https://87a6-34-88-138-74.eu.ngrok.io")!)
}
