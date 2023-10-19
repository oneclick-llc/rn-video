//
//  AppVideosManager.swift
//  Video
//
//  Created by sergeymild on 11/08/2023.
//  Copyright © 2023 Facebook. All rights reserved.
//

import Foundation

@objc
public class VideoChannel: NSObject {
    @objc
    public var videos: [String: VideoViewSwift] = [:]
    @objc
    public var laterRestore: String? {
        didSet {
            debugPrint("👺 setLAterRestore id:", laterRestore as Any)
        }
    }
    @objc
    public var backgroundRestore: String?
    
    var currentPlaying: VideoViewSwift? {
        for v in videos {
            if !v.value._paused { return v.value }
        }
        return nil
    }
    
    @objc
    public var forRestore: VideoViewSwift? {
        if let id = backgroundRestore {
            return videos[id]
        }
        return nil
    }
    
    var currentPlayingKey: String? {
        for v in videos {
            if !v.value._paused { return v.key }
        }
        return nil
    }
    
    func pauseAllVideos() {
        for video in videos {
            if video.value._paused { continue }
            video.value.setPaused(true)
        }
    }
    
    @objc
    public func video(for videoId: String) -> VideoViewSwift? {
        return videos[videoId]
    }
}

@objc
public class AppVideosManager: NSObject {
    @objc
    public static let shared = AppVideosManager()
    @objc
    public var channels: [String: VideoChannel] = [:]
    
    @objc
    public func videoId(_ video: VideoViewSwift?) -> String? {
        guard let video = video else { return nil }
        let parts = video.nativeID.components(separatedBy: ":")
        return parts[1]
    }
    
    @objc
    public func addVideo(_ video: VideoViewSwift, nativeID: String) {
        let parts = nativeID.components(separatedBy: ":")
        let channelName = parts[0]
        let id = parts[1]
        
        let channel = getChannel(channelName)
        channel?.videos[id] = video
        
        if channel?.laterRestore == id {
            video.setPaused(false)
            channel?.laterRestore = nil
        }
    }
    
    @objc
    public func removeVideo(_ nativeID: String) {
        let parts = nativeID.components(separatedBy: ":")
        let channelName = parts[0]
        let id = parts[1]
        
        let channel = getChannel(channelName)
        channel?.videos.removeValue(forKey: id)
        if channel?.videos.isEmpty == true {
            channels.removeValue(forKey: channelName)
        }
    }
    
    @objc
    public func getChannel(_ name: String) -> VideoChannel? {
        let channel = channels[name] ?? VideoChannel()
        channels[name] = channel
        return channel
    }
    
    @objc
    public func pauseVideo(channel: VideoChannel) {
        channel.currentPlaying?.setPaused(true)
    }
    
    @objc
    public func pauseAllVideos() {
        let allChannels = channels
        let allKeys = allChannels.keys
        for key in allKeys {
            allChannels[key]?.pauseAllVideos()
        }
    }
    
    @objc
    public func findFirstPlayingVideo() -> VideoViewSwift? {
        let allChannels = channels
        let allKeys = allChannels.keys
        for key in allKeys {
            if let video = allChannels[key]?.currentPlaying {
                return video
            }
        }
        return nil
    }
    
    @objc
    public func findFirstPlayingVideo(_ name: String) -> VideoViewSwift? {
        guard let channel = channels[name] else { return nil }
        return channel.currentPlaying
    }
}

