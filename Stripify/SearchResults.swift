//
//  SearchResults.swift
//  Stripify
//
//  Created by Chris Fischer on 3/15/17.
//  Copyright © 2017 CIS 195 University of Pennsylvania. All rights reserved.
//

import Foundation

class SearchResults {
    
    static fileprivate var searchResults = [Song]()
    
    static func getSong(index: Int) -> Song? {
        if (index >= searchResults.count || index < 0) {
            return nil
        }
        return searchResults[index]
    }
    
    static func getSearchResults() -> [Song] {
        return searchResults
    }
    
    static func setSearchResults(songs: [Song]) {
        searchResults = songs
    }
    
    static func clearSearchResults() {
        searchResults.removeAll()
    }
    
    static func isEmpty() -> Bool {
        return searchResults.isEmpty
    }

    static func getCount() -> Int {
        return searchResults.count
    }
}
