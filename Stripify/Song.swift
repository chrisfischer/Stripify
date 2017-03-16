//
//  Song.swift
//  Stripify
//
//  Created by Chris Fischer on 2/23/17.
//  Copyright © 2017 Chris Fischer. All rights reserved.

import Foundation

class Song {
    var name: String = ""
    var artist: String = ""
    var previewUrl: String?
    var coverArtUrl: String = ""
    
    convenience init(name: String, artist: String, previewUrl: String?, coverArtUrl: String) {
        self.init()
        self.name = name
        self.artist = artist
        self.previewUrl = previewUrl
        self.coverArtUrl = coverArtUrl
    }
    
    /*
     
    This method takes in NSData optional and returns an array of objects of class Song.
     
    */
    static func dataToSongs(_ data : Data?) -> [Song]? {
        var searchResults = [Song]()
        do {
            if let data = data, let response = try JSONSerialization.jsonObject(with: data, options:JSONSerialization.ReadingOptions(rawValue:0)) as? [String: AnyObject] {
                
                // Get the results array
                if let array: AnyObject = response["results"] {
                    for songDictonary in array as! [AnyObject] {
                        if let songDictonary = songDictonary as? [String: AnyObject] {
                            // Parse the search result
                            let previewUrl = songDictonary["previewUrl"] as? String
                            let name = songDictonary["trackName"] as? String
                            let artist = songDictonary["artistName"] as? String
                            let coverArtUrl = songDictonary["artworkUrl100"] as? String
                            searchResults.append(Song(name: name!, artist: artist!, previewUrl: previewUrl, coverArtUrl: coverArtUrl!))
                        } else {
                            print("Not a dictionary")
                        }
                    }
                } else {
                    print("Results key not found in dictionary")
                }
                
                return searchResults
                
            } else {
                print("JSON Error")
            }
        } catch let error as NSError {
            print("Error parsing results: \(error.localizedDescription)")
        }
        return nil
    }
}
