//
//  AppVideosManager.swift
//  Video
//
//  Created by sergeymild on 11/08/2023.
//  Copyright © 2023 Facebook. All rights reserved.
//

import Foundation

public class VideoChannel {
    public var videos: [String: VideoViewSwift] = [:]
    public var laterRestore: String?
    public var backgroundRestore: String?
    
    var currentPlaying: (key: String, value: VideoViewSwift)? {
        for v in videos {
            if v.value._paused { continue }
            return v
        }
        return nil
    }

    var forRestore: VideoViewSwift? {
        if let backgroundRestore {
            return videos[backgroundRestore]
        }
        return nil
    }
    
    func pauseAllVideos() {
        for video in videos {
            if video.value._paused { continue }
            video.value.setPaused(true)
        }
    }

    func video(for videoId: String) -> VideoViewSwift? {
        return videos[videoId]
    }
}

@objc
public class AppVideosManager: NSObject {
    @objc
    public static let shared = AppVideosManager()
    public var channels: [String: VideoChannel] = [:]

    public func addVideo(_ video: VideoViewSwift, nativeID: String) {
        let parts = nativeID.components(separatedBy: ":")
        let channelName = parts[0]
        let id = parts[1]
        
        let channel = getChannel(name: channelName)
        channel?.videos[id] = video
        
        if channel?.laterRestore == id {
            video.setPaused(false)
            channel?.laterRestore = nil
        }
    }

    public func removeVideo(_ nativeID: String) {
        let parts = nativeID.components(separatedBy: ":")
        let channelName = parts[0]
        let id = parts[1]
        
        let channel = getChannel(name: channelName)
        if channel?.videos.isEmpty == true {
            channels.removeValue(forKey: channelName)
        }
    }
}


// MARK: public api
extension AppVideosManager {
    @objc
    public func playVideo(_ channel: String, videoId: String) {
        guard let channel = getChannel(name: channel) else { return }
        if channel.currentPlaying?.key == videoId { return }
        self.pauseCurrentPlaying()
        if let video = channel.video(for: videoId) {
            video.setPaused(false)
        }
    }
    
    @objc
    public func pauseVideo(_ channel: String, videoId: String) {
        guard let channel = getChannel(name: channel) else { return }
        if let video = channel.video(for: videoId), !video._paused {
            video.setPaused(true)
        }
    }
    
    @objc
    public func togglePlayInBackground(_ channel: String?, playInBackground: Bool) {
        guard let videoChannel = getChannel(name: channel) else { return }
        if playInBackground {
            if let video = findFirstPlayingVideo(channelName: channel) {
                video.applicationDidEnterBackground()
                videoChannel.backgroundRestore = videoId(video)
            }
        } else {
            videoChannel.forRestore?.applicationWillEnterForeground()
            videoChannel.backgroundRestore = nil
        }

    }
    
    @objc
    public func restoreLastPlaying(_ channel: String?, shouldSeekToStart: Bool) {
        if let channel {
            let videoChannel = getChannel(name: channel)
            if let restore = videoChannel?.laterRestore {
                togglePlay(channel: channel, videoId: restore, seekToStart: true)
            }
            return
        }
        
        let keys = channels.keys
        for key in keys {
            guard let channel = channels[key] else { continue }
            if channel.laterRestore == nil { continue }
            togglePlay(
                channel: key,
                videoId: channel.laterRestore!,
                seekToStart: true
            )
            channel.laterRestore = nil
        }
    }
    
    @objc
    public func pauseCurrentPlayingWithLaterRestore(_ channel: String?) {
        if let channel {
            guard let videoChannel = getChannel(name: channel) else {
                return
            }
            if let video = findFirstPlayingVideo(channelName: channel) {
                videoChannel.laterRestore = self.videoId(video)
                video.setPaused(true)
            }
            return;
        }
        
        let keys = channels.keys
        for key in keys {
            if let channel = channels[key],
               let video = findFirstPlayingVideo(channelName: key) {
                channel.laterRestore = self.videoId(video)
                video.setPaused(true)
                channels[key] = channel
                break
            }
        }
    }
    
    @objc
    public func togglePlayVideo(_ channel: String, videoId: String) {
        let video = findFirstPlayingVideo(channelName: channel)
        if let video { pauseCurrentPlaying() }
        else { playVideo(channel, videoId: videoId) }
    }
    
    @objc
    public func toggleVideosMuted(_ muted: Bool) {
        DispatchQueue.main.async {
            let keys = self.channels.keys
            for key in keys {
                guard let channel = self.channels[key] else { continue }
                for v in channel.videos {
                    v.value.setMuted(muted)
                }
            }
        }
    }
    
    @objc
    public func pauseCurrentPlaying() {
        pauseAllVideos()
    }
}


// MARK: private api
extension AppVideosManager {
    private func togglePlay(channel: String, videoId: String, seekToStart: Bool) {
        guard let videoChannel = getChannel(name: channel) else {
            return
        }
        
        let playingVideo = findFirstPlayingVideo(channelName: channel);
        let video = videoChannel.video(for: videoId)
        let playingVideId = self.videoId(playingVideo)
        
        // pause current playing video
        if let playingVideId, playingVideId != videoId {
            playingVideo?.setPaused(true)
        }

        if let video {
            if seekToStart { video.seekToStart() }
            video.setPaused(false)
        }
    }
    
    private func videoId(_ video: VideoViewSwift?) -> String? {
        guard let video = video else { return nil }
        let parts = video.nativeID.components(separatedBy: ":")
        return parts[1]
    }

    private func getChannel(name: String?) -> VideoChannel? {
        guard let name else { return nil }
        let channel = channels[name] ?? VideoChannel()
        channels[name] = channel
        return channel
    }
    
    private func pauseVideo(channel: VideoChannel) {
        channel.currentPlaying?.value.setPaused(true)
    }
    
    private func pauseAllVideos() {
        let allChannels = channels
        let allKeys = allChannels.keys
        for key in allKeys {
            allChannels[key]?.pauseAllVideos()
        }
    }
    
    private func findFirstPlayingVideo() -> VideoViewSwift? {
        let allChannels = channels
        let allKeys = allChannels.keys
        for key in allKeys {
            if let video = allChannels[key]?.currentPlaying {
                return video.value
            }
        }
        return nil
    }
    
    private func findFirstPlayingVideo(channelName: String?) -> VideoViewSwift? {
        guard let name = channelName else { return nil }
        guard let channel = channels[name] else { return nil }
        return channel.currentPlaying?.value
    }
}
