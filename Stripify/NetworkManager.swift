//
//  NetworkManager.swift
//  Stripify
//
//  Created by Chris Fischer on 2/23/17.
//  Copyright © 2017 Chris Fischer. All rights reserved.

import Foundation

class NetworkManager {
    /*
     // MARK: - TODO: implement NetworkManager methods
     This class is responsible for querying iTunes API
     You need to use closures/completion handlers to define this function.
     
     Completion handlers: https://thatthinginswift.com/completion-handlers/
     
     Function body help: https://gist.github.com/yagil/d35b419410a2677ba04dcf6f04197444
     
     */
    
    static func queryiTunes (term: String, closure: @escaping (Data?) -> Void) {
        let defaultSession = URLSession(configuration: URLSessionConfiguration.default)
        
        var dataTask: URLSessionDataTask?
        
        if dataTask != nil {
            dataTask?.cancel()
        }
        
        let expectedCharSet = CharacterSet.urlQueryAllowed
        let searchTerm = term.addingPercentEncoding(withAllowedCharacters: expectedCharSet)!
        
        let url = URL(string: "https://itunes.apple.com/search?media=music&entity=song&term=\(searchTerm)")
        
        dataTask = defaultSession.dataTask(with: url!, completionHandler: {
            data, response, error in
            if error != nil {
                
                print(error!.localizedDescription)
                closure(nil)
                
            } else if let httpResponse = response as? HTTPURLResponse {
                
                if httpResponse.statusCode == 200 {
                    
                    if let songData = data {
                        closure(songData)
                    }
                    
                }
            }
        })
        
        dataTask?.resume()
    }
    
    static func getImage (url: URL, closure: @escaping (Data?) -> Void) {
        let defaultSession = URLSession(configuration: URLSessionConfiguration.default)
        
        var dataTask: URLSessionDataTask?
        
        if dataTask != nil {
            dataTask?.cancel()
        }
        
        dataTask = defaultSession.dataTask(with: url, completionHandler: {
            data, response, error in
            if error != nil {
                
                print(error!.localizedDescription)
                closure(nil)
                
            } else if let httpResponse = response as? HTTPURLResponse {
                
                if httpResponse.statusCode == 200 {
                    
                    if let imageData = data {
                        closure(imageData)
                    }
                    
                }
            }
        })
        
        dataTask?.resume()
    }
    
}
