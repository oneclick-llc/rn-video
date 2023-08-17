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
    var hudOffset: [String: CGFloat]? {
        didSet {
            debugPrint("++++", hudOffset)
        }
    }
    
    @objc
    var resizeMode: NSString?
    @objc
    var loop = false
    @objc
    var hudHidden = false
    @objc
    var onMuteToggle: RCTDirectEventBlock?
    @objc
    var onEndPlay: RCTDirectEventBlock?
    @objc
    var onVideoTap: RCTDirectEventBlock?
    @objc
    var onVideoDoubleTap: RCTDirectEventBlock?
    @objc
    var onVideoProgress: RCTDirectEventBlock?
    @objc
    var onLoad: RCTDirectEventBlock?
    
    var _timeObserverToken: Any?
    
    private var _muted = true
    public var _paused = true
    private var _player: AVPlayer?
    private var _playerItem: AVPlayerItem?
    private var _playerLayer = AVPlayerLayer()
    private var _videoPlayerParent = UIView()
    private var _toggleMuteButton = ToggleMuteButton()
    private var _videoDurationView = VideoDurationView()
    
    var hudX: CGFloat {
        if let h = hudOffset { return RCTConvert.cgFloat(h["x"]) }
        return 12
    }
    
    var hudY: CGFloat {
        if let h = hudOffset { return RCTConvert.cgFloat(h["y"]) }
        return 12
    }
    
    public override func didSetProps(_ changedProps: [String]!) {
        super.didSetProps(changedProps)
        if changedProps.contains("resizeMode") {
            if resizeMode == "cover" { _playerLayer.videoGravity = .resizeAspectFill }
            if resizeMode == "contain" { _playerLayer.videoGravity = .resizeAspect }
            if resizeMode == "stretch" { _playerLayer.videoGravity = .resize }
        }
        
        if changedProps.contains("hudOffset") {
            _videoDurationView.x = hudX
            _videoDurationView.y = hudY
            layoutSubviews()
            _videoDurationView.layoutSubviews()
        }
        
        if changedProps.contains("hudHidden") {
            _videoDurationView.isHidden = hudHidden
            _toggleMuteButton.isHidden = hudHidden
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
        
        
        _toggleMuteButton.addTarget(self, action: #selector(toggleMuted), for: .touchUpInside)
    }
    
    public override func layoutSubviews() {
        super.layoutSubviews()
        _videoPlayerParent.frame = .init(origin: .zero, size: self.bounds.size)
        CATransaction.begin()
        CATransaction.setAnimationDuration(0)
        _playerLayer.frame = .init(origin: .zero, size: self.bounds.size)
        CATransaction.commit()
        
        _toggleMuteButton.frame = .init(
            x: bounds.width - ToggleMuteButton.size - hudX,
            y: bounds.height - ToggleMuteButton.size - hudY,
            width: ToggleMuteButton.size,
            height: ToggleMuteButton.size
        )
        _videoDurationView.layoutSubviews()
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
        guard let _player = _player else { return }
        if paused {
            _player.pause()
            _player.rate = 0
        } else {
            _player.playImmediately(atRate: 1)
        }
    }
    
    @objc
    public func setMuted(_ muted: Bool) {
        self._muted = muted
        guard let _player = _player else { return }
        _player.volume = muted ? 0 : 1
        _player.isMuted = muted
        
        _toggleMuteButton.toggleMuted(muted)
    }
    
    @objc
    func toggleMuted() {
        onMuteToggle?(["muted": !_muted])
    }
    
    func cleanUp() {
        if _player == nil { return }
        setPaused(true)
        
        if let o = _timeObserverToken {
            _player?.removeTimeObserver(o)
            _timeObserverToken = nil
        }
        _player?.removeObserver(self, forKeyPath: "status")
        
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
        
        _videoDurationView.setTime(timeLeft)
        
        onVideoProgress?([
            "currentTime": CMTimeGetSeconds(time),
            "totalDuration": CMTimeGetSeconds(duration),
            "timeLeft": CMTimeGetSeconds(timeLeft)
        ])
        
        if CMTimeGetSeconds(timeLeft) == 0 {
            _player.seek(to: .zero)
            onEndPlay?(nil)
            if loop { _player.playImmediately(atRate: 1) }
            else { setPaused(true) }
        }
    }
    
    func setupUI() {
        if _videoPlayerParent.superview != nil { return }
        addSubview(_videoPlayerParent)
        _videoPlayerParent.layer.addSublayer(_playerLayer)

        _playerLayer.videoGravity = .resizeAspectFill
        if resizeMode == "cover" { _playerLayer.videoGravity = .resizeAspectFill }
        if resizeMode == "contain" { _playerLayer.videoGravity = .resizeAspect }
        if resizeMode == "stretch" { _playerLayer.videoGravity = .resize }

        _toggleMuteButton.toggleMuted(_muted)
        addSubview(_toggleMuteButton)
        
        self.setMuted(_muted)
        
        _videoDurationView.x = hudX
        _videoDurationView.y = hudY
        addSubview(_videoDurationView)
        
        applyGestures()
        
        let interval = CMTimeMakeWithSeconds(1.0, preferredTimescale: 60000)
        
        _player?.addPeriodicTimeObserver(
            forInterval: interval,
            queue: .main,
            using: { [weak self] time in
                self?.sendProgressUpdate(time: time)
            }
        )
        
        _player?.addObserver(self, forKeyPath: "status", options: [.new, .initial], context: nil)
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
                onLoad?(nil)
                _videoDurationView.setTime(_player?.currentItem?.asset.duration ?? .zero)
            }
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
