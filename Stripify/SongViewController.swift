//
//  SongViewController.swift
//  Stripify
//
//  Created by Chris Fischer on 2/23/17.
//  Copyright © 2017 Chris Fischer. All rights reserved.

import UIKit
import AVFoundation

class SongViewController: UIViewController {
    
    var gradientLayer: CAGradientLayer!
    
    var song: Song?
    var songIndex: Int?
    var audioPlayer : AVPlayer?
    
    var duration : Double?
    
    @IBOutlet weak var progressBar: UIProgressView!
    @IBOutlet weak var songNameLabel: UILabel!
    @IBOutlet weak var artistLabel: UILabel!
    @IBOutlet weak var playPauseButton: UIButton!
    @IBOutlet weak var timePassedLabel: UILabel!
    @IBOutlet weak var songDurationLabel: UILabel!
    @IBOutlet weak var coverArtView: UIImageView!
    @IBOutlet weak var container: UIView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        songNameLabel.text = song?.name
        artistLabel.text = song?.artist
        progressBar.progressTintColor = UIColor(red: 105/255.0, green: 106/255.0, blue: 236/255.0, alpha: 1)
        
        setUpCoverArt()
        
        let imageUrl = URL(string: changeTo600(url: (song?.coverArtUrl)!))
        
        NetworkManager.getImage(url: imageUrl!, closure: updateCoverArt)
        
        setupPlayer()
        
    
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        createGradientLayer()
    }
    
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)
        self.gradientLayer.frame = CGRect(origin: CGPoint(x: 0, y: 0), size: size)
        coordinator.animate(alongsideTransition: nil) { _ in
                        
        }
    }
    
    func createGradientLayer() {
        gradientLayer = CAGradientLayer()
        
        gradientLayer.frame = view.bounds
        
        gradientLayer.colors = [UIColor.white.cgColor, UIColor.black.cgColor]
        
        view.layer.insertSublayer(gradientLayer, at: 0)
    }
    
    func setUpCoverArt() {
        // container for shadow
        container.layer.shadowColor = UIColor(white: 0.0, alpha: 0.5).cgColor
        container.layer.shadowOffset = CGSize(width: 0.0, height: 0.0)
        container.layer.shadowOpacity = 1.0
        container.layer.shadowRadius = 7.0
        
        coverArtView.layer.cornerRadius = 8.0
        coverArtView.clipsToBounds = true
        
        container.addSubview(coverArtView)
        
    }
    
    func updateCoverArt (data: Data?) {
        
        if let imageData = data {
                DispatchQueue.main.async {
                    self.coverArtView.image = UIImage(data: imageData)
                    self.coverArtView.layer.cornerRadius = 8.0
                    self.coverArtView.clipsToBounds = true
                }
        } else {
            
        }
    }

    
    func setupPlayer() {
        let urlPath = song?.previewUrl
        let url : URL = URL(string: urlPath!)!
        
        DispatchQueue.main.async {
            
            self.audioPlayer = AVPlayer(url: url)
            self.audioPlayer?.allowsExternalPlayback = true
            
            
            let interval = CMTime(seconds: 0.1, preferredTimescale: 600)
         
            self.audioPlayer?.addPeriodicTimeObserver(forInterval: interval, queue: nil, using: { (time : CMTime) in
                self.updateCurrentProgress(time)
                
            })
            
            self.populateSongDurationLabel()
        }
        
    }
    
    func populateSongDurationLabel() {
        if let totalSeconds = audioPlayer?.currentItem?.asset.duration.seconds {
            duration = totalSeconds
            let intSeconds = Int(totalSeconds)
            
            let minutes : Int = intSeconds / 60
            let seconds : Int = intSeconds - minutes * 60
            
            songDurationLabel.text = "\(minutes):\(seconds)"
            
        }
    }
    
    func updateCurrentProgress(_ time : CMTime) {
        let totalSeconds = time.seconds
        let intSeconds = Int(totalSeconds)
        
        let minutes : Int = intSeconds / 60
        let seconds : Int = intSeconds - minutes * 60
        
        timePassedLabel.text = "\(minutes):\(String(format: "%02d", seconds))"
        
        let percentage = totalSeconds / duration!
        progressBar.setProgress(Float(percentage), animated: true)
    }
    
    func changeTo600(url: String) -> String {
        return url.replacingOccurrences(of: "100x100", with: "600x600")
        
    }
    
    // MARK: IBActions
    
    @IBAction func playPause(_ sender: Any) {
        if audioPlayer != nil {
            
            if (audioPlayer!.rate != 0 && audioPlayer!.error == nil) {
                audioPlayer?.pause()
                playPauseButton.setImage(#imageLiteral(resourceName: "play"), for: .normal)
                
            } else {
                audioPlayer?.play()
                playPauseButton.setImage(#imageLiteral(resourceName: "pause"), for: .normal)

            }
        }
    }
    
    // MARK: Navigation
    
    override func viewWillDisappear(_ animated: Bool) {
        if (audioPlayer!.rate != 0 && audioPlayer!.error == nil) {
            audioPlayer?.pause()
        }
    }
}
