//
//  SearchViewController.swift
//  Stripify
//
//  Created by Chris Fischer on 2/23/17.
//  Copyright © 2017 Chris Fischer. All rights reserved.

import UIKit

class songTableViewCell: UITableViewCell {
    
    @IBOutlet weak var songTitleLabel: UILabel!
    @IBOutlet weak var artistNameLabel: UILabel!
    @IBOutlet weak var coverArtImageView: UIImageView!
    
}

class recentSearchTableViewCell: UITableViewCell {
    
    @IBOutlet weak var searchLabel: UILabel!
    
}


class SearchViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UISearchBarDelegate, UIScrollViewDelegate {
    
    var isSearchMode: Bool = true
    var isScrolling: Bool = false
    
    var recentSearches = [String]()
    
    
    var thumbnails = [String: UIImage]()
    
    lazy var searchBar: UISearchBar = UISearchBar(frame: CGRect(x: 0, y: 0, width: 300, height: 20))
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var noRecentView: UIView!
    @IBOutlet weak var noRecentLabels: UIStackView!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.delegate = self
        tableView.dataSource = self
        
        navigationController?.navigationBar.barTintColor = UIColor(red: 105/255.0, green: 106/255.0, blue: 236/255.0, alpha: 1)
        
        searchBar.delegate = self
        searchBar.placeholder = "Search"                // set placeholder text
        searchBar.tintColor = UIColor.darkGray          // change cursor color
        searchBar.returnKeyType = .search               // change return button
        searchBar.keyboardAppearance = .dark

        
        // change cancel button color to white
        let cancelButtonAttributes: NSDictionary = [NSForegroundColorAttributeName: UIColor.white]
        UIBarButtonItem.appearance().setTitleTextAttributes(cancelButtonAttributes as? [String : AnyObject], for: .normal)
        
        if (SearchResults.isEmpty()) {
            noRecentView.isHidden = false
            noRecentLabels.isHidden = false
        } else {
            noRecentView.isHidden = true
            noRecentLabels.isHidden = true
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        searchBar.resignFirstResponder()
    }
    
    override func awakeFromNib() {
        // setup search bar
        self.navigationItem.titleView = searchBar
        
    }
    
    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
        //stop the current scrolling
        tableView.setContentOffset(tableView.contentOffset, animated: false)
        searchBar.setShowsCancelButton(true, animated: true)
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        
        searchBar.resignFirstResponder()
        searchBar.setShowsCancelButton(false, animated: true)
        
        if (searchBar.text! == "" && recentSearches.isEmpty) {
            noRecentView.isHidden = false
            noRecentLabels.isHidden = false
        }
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        
        searchBar.resignFirstResponder()
        searchBar.setShowsCancelButton(false, animated: true)
        
        // add search term to recent searches
        if let term = searchBar.text {
            if (!recentSearches.contains(term)) {
                recentSearches.append(term)
            }
        }
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        
        noRecentView.isHidden = true
        noRecentLabels.isHidden = true
        
        if (searchText != "") {
            isSearchMode = true
            NetworkManager.queryiTunes(term: searchText, closure: updateTable)
        } else {
            
            // if the clear text button is pressed
            clearTable()
            isSearchMode = false
            tableView.reloadData()
            
            if(recentSearches.isEmpty) {
                noRecentView.isHidden = false
                noRecentLabels.isHidden = false
            }
            
        }
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if (!isScrolling) {
            if (searchBar.isFirstResponder) {
                searchBar.resignFirstResponder()
                searchBar.setShowsCancelButton(false, animated: true)
            }
        }
        if (tableView.contentOffset.y <= 0.0) {
            isScrolling = false
        }
        
    }
    
    func updateTable (data: Data?) {
        
        if (!SearchResults.isEmpty()) {
            clearTable()
        }
        
        if let songData = data {
            SearchResults.setSearchResults(songs: Song.dataToSongs(songData)!)
            
            if (!SearchResults.isEmpty()) {
                loadThumbnails(songs: SearchResults.getSearchResults())
            }
        } else {
            
        }
    }
    
    func clearTable() {
        SearchResults.clearSearchResults()
        thumbnails.removeAll()
    }
    
    func loadThumbnails(songs: [Song]) {
        var count : Int = 0
        for song in songs {
            if self.thumbnails.index(forKey: song.coverArtUrl) == nil {
                let imageUrl = URL(string: song.coverArtUrl)
                
                let task = URLSession.shared.dataTask(with: imageUrl!) { (data, response, error) in
                    if (error == nil) {
                        if let image = UIImage(data: data!) {
                            self.thumbnails[song.coverArtUrl] = image
                        }
                    }
                    if (count == songs.count - 1) {
                        DispatchQueue.main.async {
                            //update the table
                            self.tableView.reloadData()
                            if (self.tableView.contentOffset.y > 0.0) {
                                self.isScrolling = true
                            }
                            if (self.tableView.contentOffset.y > 0) {
                                self.tableView.scrollToRow(at: IndexPath(row: 0, section: 0), at: .top, animated: true)
                            }
                        }
                    }
                    count = count + 1
                }
                task.resume()
            }
        }
        
        
    }
    
    
    // MARK: - Table view data source
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if (isSearchMode) {
            return SearchResults.getCount()
        } else {
            return recentSearches.count
        }
        
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if (isSearchMode) {
            let cell = tableView.dequeueReusableCell(withIdentifier: "songCell", for: indexPath) as! songTableViewCell
            
            // Configure the cell...
            let row : Int = indexPath.row
            
            guard let song = SearchResults.getSong(index: row) else {
                return cell
            }
            
            cell.songTitleLabel?.text = song.name
            cell.artistNameLabel?.text = song.artist
            
            cell.coverArtImageView.image = thumbnails[song.coverArtUrl]
            cell.coverArtImageView.layer.cornerRadius = 3.0
            cell.coverArtImageView.clipsToBounds = true
            
            let view = UIView()
            view.backgroundColor = UIColor(red: 105/255.0, green: 106/255.0, blue: 236/255.0, alpha: 1)
            cell.selectedBackgroundView = view
            
            
            return cell
        } else {
            let cell = tableView.dequeueReusableCell(withIdentifier: "recentSearchCell", for: indexPath) as! recentSearchTableViewCell
            
            // Configure the cell...
            let row : Int = indexPath.row
            let search : String = recentSearches[recentSearches.count - row - 1]
            
            cell.searchLabel.text = search
            
            let view = UIView()
            view.backgroundColor = UIColor(red: 105/255.0, green: 106/255.0, blue: 236/255.0, alpha: 1)
            cell.selectedBackgroundView = view
            
            return cell
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if (isSearchMode) {
            return 70
        } else {
            return 50
        }
    }

    
    // MARK: TableView Delegate Methods
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if (!isSearchMode) {
            
            // selecting a recent search
            isSearchMode = true
            
            let term = recentSearches[recentSearches.count - indexPath.row - 1]
            NetworkManager.queryiTunes(term: term, closure: updateTable)
            
            searchBar.text = term
            searchBar.resignFirstResponder()
            searchBar.setShowsCancelButton(false, animated: true)
            
        } else {
            
            // add search term to recent searches
            if let term = searchBar.text {
                if (!recentSearches.contains(term)) {
                    recentSearches.append(term)
                }
            }
        }
    }
    
    
    // MARK: Navigation
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if let destination = segue.destination as? SongViewController {
            let row = (tableView.indexPathForSelectedRow?.row)!
            // Pass the selected object to the new view controller.
            destination.song = SearchResults.getSong(index: row)
            destination.songIndex = row
            
            tableView.deselectRow(at: IndexPath(row: row, section: 0), animated: true)
            searchBar.setShowsCancelButton(false, animated: true)
        }
        
    }
    
    override func shouldPerformSegue(withIdentifier identifier: String, sender: Any?) -> Bool {
        let row = (tableView.indexPathForSelectedRow?.row)!
        let song = SearchResults.getSong(index: row)
        if song?.previewUrl == nil {
            let alert = UIAlertController(title: "Oops", message: "No preview was found.", preferredStyle: UIAlertControllerStyle.alert)
            let action = UIAlertAction(title: "Okay", style: UIAlertActionStyle.cancel, handler: nil)
            alert.addAction(action)
            self.present(alert, animated: true) {
                self.tableView.deselectRow(at: IndexPath(row: row, section: 0), animated: true)
            }
            
            return false
        } else {
            return true
        }
    }
    
    
    
}
