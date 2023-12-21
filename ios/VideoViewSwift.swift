//
//  VideoViewSwift.swift
//  Video
//
//  Created by sergeymild on 11/08/2023.
//  Copyright © 2023 Facebook. All rights reserved.
//

import UIKit
import React
import Photos

@objc
public class VideoViewSwift: UIView {
    @objc
    var videoResizeMode: NSString?
    @objc
    var loop = false
    @objc
    var progressUpdateInterval = 1.0
    @objc
    var onVideoEnd: RCTDirectEventBlock?
    @objc
    var onVideoBuffer: RCTDirectEventBlock?
    @objc
    var onVideoTap: RCTDirectEventBlock?
    @objc
    var onShowPoster: RCTDirectEventBlock?
    @objc
    var onVideoDoubleTap: RCTDirectEventBlock?
    @objc
    var onVideoProgress: RCTDirectEventBlock?
    @objc
    var onVideoError: RCTDirectEventBlock?
    @objc
    var onVideoLoad: RCTDirectEventBlock?
    
    var _timeObserverToken: Any?
    
    public var _muted = true
    public var _paused = true
    private var _player: AVPlayer?
    private var _playerItem: AVPlayerItem?
    private var _playerLayer = AVPlayerLayer()
    private var _videoPlayerParent = UIView()
    private var _isPosterPresent = true
    
    private func updateReizeMode() {
        _playerLayer.videoGravity = .resizeAspectFill
        if videoResizeMode == "cover" { _playerLayer.videoGravity = .resizeAspectFill }
        if videoResizeMode == "contain" { _playerLayer.videoGravity = .resizeAspect }
        if videoResizeMode == "stretch" { _playerLayer.videoGravity = .resize }
    }
    
    public override func didSetProps(_ changedProps: [String]!) {
        super.didSetProps(changedProps)
        if changedProps.contains("videoResizeMode") {
            updateReizeMode()
        }
        
        AppVideosManager.shared.addVideo(self, nativeID: self.nativeID)
    }
    
    func initializePlayer() {
        _player = AVPlayer(playerItem: _playerItem)
        _player?.automaticallyWaitsToMinimizeStalling = false
        if #available(iOS 12.0, *) {
            _player?.preventsDisplaySleepDuringVideoPlayback = true
        }
        _playerLayer.player = _player
        if !_paused { AppVideosManager.shared.pauseCurrentPlaying() }
        setPaused(_paused)
        setupUI()
    }
    
    func applyGestures() {
        let onVideoTap = UITapGestureRecognizer(target: self, action: #selector(didVideoTap))
        addGestureRecognizer(onVideoTap)
        
        let onVideoDoubleTap = UITapGestureRecognizer(target: self, action: #selector(didVideoDoubleTap))
        onVideoDoubleTap.numberOfTapsRequired = 2
        onVideoTap.require(toFail: onVideoDoubleTap)
        addGestureRecognizer(onVideoDoubleTap)
    }
    
    public override func layoutSubviews() {
        super.layoutSubviews()
        _videoPlayerParent.frame = .init(origin: .zero, size: self.bounds.size)
        CATransaction.begin()
        CATransaction.setAnimationDuration(0)
        _playerLayer.frame = .init(origin: .zero, size: self.bounds.size)
        CATransaction.commit()
    }
    
    @objc
    func didVideoTap() {
        onVideoTap?(nil)
    }
    
    @objc
    func didVideoDoubleTap() {
        onVideoDoubleTap?(nil)
    }
    
    @objc
    public func setPaused(_ paused: Bool) {
        self._paused = paused
        guard let _player else { return }
        if paused {
            _player.pause()
            _player.rate = 0
        } else {
            _player.playImmediately(atRate: 1)
            showPoster(show: false)
        }
    }
    
    func showPoster(show: Bool) {
        if _isPosterPresent && !show {
            onShowPoster?(["show": false])
            _isPosterPresent = false
        } else if !_isPosterPresent && show {
            onShowPoster?(["show": true])
            _isPosterPresent = true
        }
    }
    
    @objc
    public func setMuted(_ muted: Bool) {
        self._muted = muted
        guard let _player = _player else { return }
        _player.volume = muted ? 0 : 1
        _player.isMuted = muted
    }
    
    @objc
    public func setAutoplay(_ autoplay: Bool) {
        self._paused = !autoplay
    }
    
    func cleanUp() {
        if _player == nil { return }
        setPaused(true)
        
        if let o = _timeObserverToken {
            _player?.removeTimeObserver(o)
            _timeObserverToken = nil
        }
        _player?.removeObserver(self, forKeyPath: "status")
        _player?.removeObserver(self, forKeyPath: "playbackBufferEmpty")
        _player?.removeObserver(self, forKeyPath: "playbackLikelyToKeepUp")
        
        _player = nil;
        _playerItem = nil;
        _playerLayer.removeFromSuperlayer()
        _playerLayer.player = nil
        AppVideosManager.shared.removeVideo(self.nativeID)
    }
    
    func sendProgressUpdate(time: CMTime) {
        guard let _player = _player else { return }
        let duration = _player.currentItem?.duration ?? .zero;
        let timeLeft = CMTimeSubtract(duration, time);
        
        onVideoProgress?([
            "currentTime": CMTimeGetSeconds(time),
            "totalDuration": CMTimeGetSeconds(duration),
            "timeLeft": CMTimeGetSeconds(timeLeft)
        ])
        
        if CMTimeGetSeconds(timeLeft) == 0 {
            _player.seek(to: .zero)
            onVideoEnd?(nil)
            if loop {
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) { [weak self] in
                    if self?._paused == true { return }
                    _player.play()
                }
            }
            else { setPaused(true) }
        }
    }
    
    func setupUI() {
        if _videoPlayerParent.superview != nil { return }
        addSubview(_videoPlayerParent)
        _videoPlayerParent.layer.addSublayer(_playerLayer)

        updateReizeMode()

        self.setMuted(_muted)
        
        applyGestures()
        let progress = progressUpdateInterval
        debugPrint("===-=", progressUpdateInterval)
        let interval = CMTimeMakeWithSeconds(progress, preferredTimescale: 60000)
        
        _player?.addPeriodicTimeObserver(
            forInterval: interval,
            queue: .main,
            using: { [weak self] time in
                self?.sendProgressUpdate(time: time)
            }
        )
        
        _player?.addObserver(self, forKeyPath: "status", options: [.new, .initial], context: nil)
        _player?.addObserver(self, forKeyPath: "playbackBufferEmpty", options: [.new], context: nil)
        _player?.addObserver(self, forKeyPath: "playbackLikelyToKeepUp", options: [.new], context: nil)
    }
    
    public override func removeFromSuperview() {
        super.removeFromSuperview()
        cleanUp()
    }
    
    @objc
    public func applicationDidEnterBackground() {
        _playerLayer.player = nil
    }
    
    @objc
    public func applicationWillEnterForeground() {
        _playerLayer.player = _player
    }
    
    public override func observeValue(
        forKeyPath keyPath: String?,
        of object: Any?,
        change: [NSKeyValueChangeKey : Any]?,
        context: UnsafeMutableRawPointer?
    ) {
        
        if keyPath == "status" {
            if _player == nil { return }
            if _player?.status == .readyToPlay {
                onVideoLoad?(nil)
            }
            
            if _player?.status == .failed {
                onVideoError?(nil)
            }
        }
        
        if keyPath == "playbackBufferEmpty" {
            onVideoBuffer?(["isBuffering": true])
        }
        
        if keyPath == "playbackLikelyToKeepUp" {
            onVideoBuffer?(["isBuffering": false])
        }
    }
    
    @objc
    public func seekToStart() {
        guard let item = _player?.currentItem else { return }
        if item.status == .readyToPlay {
            item.seek(to: .zero, completionHandler: nil)
        }
    }
    
    @objc
    public func seekTo(duration: Double) {
        _player?.seek(to: CMTime(seconds: duration, preferredTimescale: 60000))
    }
    
    @objc
    func setVideoUri(_ uri: String) {
        if !uri.starts(with: "ph://") {
            _playerItem = AVPlayerItem(asset: AVAsset(url: URL(string: uri)!))
            return initializePlayer()
        }
        
        let fetchOpts = PHFetchOptions()
        fetchOpts.fetchLimit = 1
        guard let asset = PHAsset.fetchAssets(
            withLocalIdentifiers: [uri.replacingOccurrences(of: "ph://", with: "")],
            options: fetchOpts).firstObject else { return }
        
        let requestOpts = PHVideoRequestOptions()
        requestOpts.version = .current
        PHImageManager.default().requestPlayerItem(
            forVideo: asset,
            options: requestOpts) { [weak self] item, _ in
                guard let self = self, let item = item else { return }
                self._playerItem = item
                self.initializePlayer()
            }
    }
}
