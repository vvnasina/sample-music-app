//
//  TMAVPlayer.swift
//  TestMusicApp
//
//  Created by Vishnu on 09/05/17.
//
//

import Foundation
import MediaPlayer

class TMAVPlayer: NSObject {
    
    private var audioPlayer: AVPlayer = AVPlayer()
    static let shared = TMAVPlayer()
    
    let songs = MPMediaQuery.songs().items ?? []
    private var currentSongIndex: Int! = nil
    
    override private init() {
        if #available(iOS 9.3, *) {
            MPMediaLibrary.requestAuthorization { (status) in
                // Not Handling the status You should allow the Music base access
                switch status {
                case .authorized: break
                case .denied: break
                case .notDetermined: break
                case .restricted: break
                }
            }
        }
    }
    
    // MARK: - Computed properties
    
    var currentPlayingItem: MPMediaItem? {
        return songs[currentSongIndex]
    }
    
    var currentPlayingItemTitle: String? {
        return songs[currentSongIndex].title
    }
    
    var isAudioPlaying: Bool {
        if audioPlayer.rate == 0.0 {
            return false
        }
        return true
    }
    
    var currentPlayingTime: Float {
        return Float(CMTimeGetSeconds(audioPlayer.currentTime()))
    }
    
    // MARK: - Utility methods
    
    func prepareToPlay(songIndex: Int) {
        // Check songs availablility, terminate on fail condition
        if songIndex < 0 || songIndex >= songs.count {
            return
        }
        // Check is asset url is available or not
        if let assetURL = songs[songIndex].assetURL {
            // Maintains the current playing song media item
            currentSongIndex = songIndex
            // Creating player item upon the media item
            let playerItem = AVPlayerItem(url: assetURL)
            
            // Remove early added observer
            NotificationCenter.default.removeObserver(self)
            
            // Subscribe to the AVPlayerItem's DidPlayToEndTime notification.
            NotificationCenter.default.addObserver(self, selector: #selector(itemDidFinishPlaying), name: NSNotification.Name.AVPlayerItemDidPlayToEndTime, object: playerItem)
            
            audioPlayer.replaceCurrentItem(with: playerItem)
            audioPlayer.play()
        }
    }
    
    func playBack() {
        // Check audio is playing
        if isAudioPlaying {
            audioPlayer.pause()
        }
        else {
            audioPlayer.play()
        }
    }
    
    func previous() {
        let previousSongIndex = currentSongIndex - 1
        if previousSongIndex >= 0 {
            prepareToPlay(songIndex: previousSongIndex)
        }
    }
    
    func next() {
        let nextSongIndex = currentSongIndex + 1
        if nextSongIndex < songs.count {
            prepareToPlay(songIndex: nextSongIndex)
        }
    }
    
    func stop() {
        audioPlayer.rate = 0.0
    }
    
    func seekToTime(time: Float) {
        audioPlayer.seek(to: CMTimeMake(Int64(time), 1))
    }
    
    // MARK: - Observer methods
    
    func itemDidFinishPlaying() {
        // After finishing song play next song
        next()
    }
    
}

// Extending the Notification name on the basis of new song did start playing
extension NSNotification.Name {
    
    static var TMAVPlayerSongDidStartPlaying: String {
        return "TMAVPlayerSongDidStartPlaying"
    }
    
}

