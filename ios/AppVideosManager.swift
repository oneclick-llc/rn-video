//
//  AppVideosManager.swift
//  Video
//
//  Created by sergeymild on 11/08/2023.
//  Copyright © 2023 Facebook. All rights reserved.
//

import Foundation

public typealias LookyVideoView = VideoViewSwift

public class VideoChannel {
    var videos: [String: LookyVideoView] = [:]
    var laterRestore: String?
    var backgroundRestore: String?

    var currentPlaying: (key: String, value: LookyVideoView)? {
        for v in videos {
            if v.value._paused { continue }
            return v
        }
        return nil
    }

    var forRestore: LookyVideoView? {
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

    func toggleMuted(_ muted: Bool) {
        for video in videos {
            video.value.updateMuted(muted)
        }
    }

    func video(for videoId: String) -> LookyVideoView? {
        return videos[videoId]
    }
}

@objc
public class AppVideosManager: NSObject {
    @objc
    public static let shared = AppVideosManager()
    public var channels: [String: VideoChannel] = [:]

    public func addVideo(_ video: LookyVideoView, nativeID: String) {
        let parts = nativeID.components(separatedBy: ":")
        let channelName = parts[0]
        let id = parts[1]

        let channel = getChannel(name: channelName)
        channel?.videos[id] = video

        //debugPrint("🍓 addVideo", channelName, id)

        if channel?.laterRestore == id {
            video.setPaused(false)
            channel?.laterRestore = nil
        } else {
            video.showPoster(show: true)
        }
    }

    public func removeVideo(_ nativeID: String) {
        let parts = nativeID.components(separatedBy: ":")
        let channelName = parts[0]
        let id = parts[1]
        //debugPrint("🍓 removeVideo", channelName, id)

        let channel = getChannel(name: channelName)
        channel?.videos.removeValue(forKey: id)
        if channel?.videos.isEmpty == true {
            channels.removeValue(forKey: channelName)
        }
    }
}


// MARK: public api
extension AppVideosManager {
    @objc
    public func playVideo(_ channelName: String, videoId: String) {
        guard let channel = getChannel(name: channelName) else { return }
        if channel.currentPlaying?.key == videoId { return }
        self.pauseCurrentPlaying()
        if let video = channel.video(for: videoId), video._paused {
            debugPrint("🍓 playVideo", channelName, videoId)
            video.setPaused(false)
        }
    }

    @objc
    public func pauseVideo(_ channelName: String, videoId: String) {
        guard let channel = getChannel(name: channelName) else { return }
        if let video = channel.video(for: videoId), !video._paused {
            debugPrint("🍓 pauseVideo", channelName, videoId)
            video.setPaused(true)
        }
    }

    @objc
    public func togglePlayInBackground(_ channelName: String?, playInBackground: Bool) {
        guard let videoChannel = getChannel(name: channelName) else { return }
        if playInBackground {
            if let video = findFirstPlayingVideo(channelName: channelName) {
                debugPrint("🍓 togglePlayInBackground", channelName as Any, videoId(video) as Any)
                video.applicationDidEnterBackground()
                videoChannel.backgroundRestore = videoId(video)
            }
        } else {
            videoChannel.forRestore?.applicationWillEnterForeground()
            videoChannel.backgroundRestore = nil
        }

    }

    @objc
    public func restoreLastPlaying(_ channelName: String?, shouldSeekToStart: Bool) {
        pauseAllVideos()
        debugPrint("🍓 restoreLastPlaying.knownChannel", channelName as Any)
        if let channelName {
            let videoChannel = getChannel(name: channelName)
            if let restore = videoChannel?.laterRestore {
                togglePlay(channel: channelName, videoId: restore, seekToStart: true)
            }
            return
        }

        for entry in channels {
            if entry.value.laterRestore == nil { continue }
            togglePlay(
                channel: entry.key,
                videoId: entry.value.laterRestore!,
                seekToStart: true
            )
            entry.value.laterRestore = nil
        }
    }

    @objc
    public func pauseCurrentPlayingWithLaterRestore(_ channelName: String?) {
        if let channelName {
            guard let channel = getChannel(name: channelName) else { return }
            if let video = channel.currentPlaying?.value {
                channel.laterRestore = videoId(video)
                video.setPaused(true)
                debugPrint("🍓 pauseCurrentPlayingWithLaterRestore.knownChannel", channelName as Any, videoId(video) as Any)
            }
            return;
        }

        for entry in channels {
            let channel = entry.value
            let video = channel.currentPlaying?.value
            channel.laterRestore = videoId(video)
            video?.setPaused(true)
            debugPrint("🍓 pauseCurrentPlayingWithLaterRestore", entry.key, videoId(video) as Any)
        }
    }

    @objc
    public func togglePlayVideo(_ channelName: String, videoId: String) {
        let video = findFirstPlayingVideo(channelName: channelName)
        if video != nil { pauseCurrentPlaying() }
        else { playVideo(channelName, videoId: videoId) }
    }

    @objc
    public func toggleVideosMuted(_ muted: Bool) {
        DispatchQueue.main.async {
            for entry in self.channels {
                entry.value.toggleMuted(muted)
            }
        }
    }

    @objc
    public func pauseCurrentPlaying() {
        for entry in channels {
            let channel = entry.value
            if let video = channel.currentPlaying?.value {
                debugPrint("🍓 pauseCurrentPlaying", video.nativeID ?? "")
                video.setPaused(true)
            }
        }
    }

    @objc
    public func pauseAll(_ channelName: String) {
        guard let channel = getChannel(name: channelName) else {
            return
        }

        for entry in channel.videos {
            entry.value.setPaused(true)
        }
    }

    @objc
    public func playAll(_ channelName: String) {
        guard let channel = getChannel(name: channelName) else {
            return
        }

        for entry in channel.videos {
            entry.value.setPaused(false)
        }
    }

    @objc
    public func isPaused(_ channelName: String, videoId: String) -> Bool {
        return getChannel(name: channelName)?.video(for: videoId)?._paused == true
    }

    @objc
    public func isMuted(_ channelName: String, videoId: String) -> Bool {
        return getChannel(name: channelName)?.video(for: videoId)?._muted == true
    }

    @objc
    public func seek(_ channelName: String, videoId: String, duration: Double) {
        getChannel(name: channelName)?.video(for: videoId)?.seekTo(duration: duration)
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

    private func videoId(_ video: LookyVideoView?) -> String? {
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
        for entry in channels {
            entry.value.pauseAllVideos()
        }
    }

    private func findFirstPlayingVideo() -> LookyVideoView? {
        for entry in channels {
            if let v = entry.value.currentPlaying { return v.value }
        }
        return nil
    }

    private func findFirstPlayingVideo(channelName: String?) -> LookyVideoView? {
        guard let name = channelName else { return nil }
        guard let channel = getChannel(name: name) else { return nil }
        return channel.currentPlaying?.value
    }
}
