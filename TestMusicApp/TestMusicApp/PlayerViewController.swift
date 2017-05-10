//
//  PlayerViewController.swift
//  TestMusicApp
//
//  Created by Vishnu on 08/05/17.
//
//

import UIKit

class PlayerViewController: UIViewController {
    
    @IBOutlet fileprivate weak var songLabel: UILabel!
    @IBOutlet fileprivate weak var playButton: UIButton!
    @IBOutlet fileprivate weak var seekSlider: UISlider!
    
    // Here using TMAVPlayer which build upon the AVPlayer
    fileprivate let audioPlayer = TMAVPlayer.shared
    private var audioTimer: Timer?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Adding observer for did change the current playing song
        NotificationCenter.default.addObserver(self, selector: #selector(playNotificationMethod), name: NSNotification.Name(rawValue: NSNotification.Name.TMAVPlayerSongDidStartPlaying), object: nil)
        
        // Catch the play state changed actions
        NotificationCenter.default.addObserver(self, selector: #selector(playBackStateChanged), name: NSNotification.Name(rawValue: NSNotification.Name.TMAVPlayerPlayStateChanged), object: nil)
        
        // Timer to update the song progress
        self.audioTimer = Timer.scheduledTimer(timeInterval: 1.0, target: self, selector: #selector(updateCurrentPlayTime), userInfo: nil, repeats: true)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    deinit {
        // Remove observer for the class here
        NotificationCenter.default.removeObserver(self)
    }
    
    // MARK: - Observer method
    
    func playNotificationMethod() {
        songLabel.text = audioPlayer.currentPlayingItemTitle
        // Change play button state if audio is already playing
        if audioPlayer.isAudioPlaying {
            playButton.isSelected = true
        }
        // Intialize the slider every time when new song is getting played
        seekSlider.minimumValue = 0.0
        seekSlider.maximumValue = Float(audioPlayer.currentPlayingItem?.playbackDuration ?? 0.0)
        seekSlider.value = audioPlayer.currentPlayingTime
    }
    
    func playBackStateChanged() {
        if audioPlayer.isAudioPlaying {
            playButton.isSelected = true
        }
        else {
            playButton.isSelected = false
        }
    }
    
    func updateCurrentPlayTime() {
        if audioPlayer.isAudioPlaying {
            seekSlider.value = audioPlayer.currentPlayingTime
        }
    }

    // MARK: - Button Actions
    
    @IBAction func playButtonAction(_ sender: UIButton) {
        // Change play and pause button titles
        sender.isSelected = !(sender.isSelected)
        audioPlayer.playBack()
    }
    
    @IBAction func previousButtonAction(_ sender: UIButton) {
        audioPlayer.previous()
    }
    
    @IBAction func nextButtonAction(_ sender: UIButton) {
        audioPlayer.next()
    }
    
    @IBAction func seekSliderChanged(_ sender: UISlider) {
        audioPlayer.seekToTime(time: sender.value)
    }
    
}

extension PlayerViewController: UITableViewDataSource, UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return audioPlayer.songs.count 
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cellIdentifier = "SongCell"
        var songCell: UITableViewCell!
        songCell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier)
        if nil == songCell {
            songCell = UITableViewCell(style: .default, reuseIdentifier: cellIdentifier)
            songCell.textLabel?.textColor = .black
            songCell.selectionStyle = .none
        }
        songCell.textLabel?.text = audioPlayer.songs[indexPath.row].title
        
        return songCell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        audioPlayer.prepareToPlay(songIndex: indexPath.row)
        playButton.isSelected = true        
    }
    
}
