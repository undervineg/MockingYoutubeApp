//
//  VideoPlayerView.swift
//  YoutubeApp
//
//  Created by 심승민 on 11/03/2019.
//  Copyright © 2019 심승민. All rights reserved.
//

import UIKit
import AVFoundation

final class VideoPlayerView: UIView {
    
    // MARK: UI
    private let activityIndicatorView: UIActivityIndicatorView = {
        let i = UIActivityIndicatorView(style: .white)
        i.translatesAutoresizingMaskIntoConstraints = false
        i.startAnimating()
        return i
    }()
    
    private lazy var controlsContainerView: UIView = {
        let gradientLayer = CAGradientLayer()
        gradientLayer.frame = bounds
        gradientLayer.colors = [UIColor.clear.cgColor, UIColor.black.cgColor]
        gradientLayer.locations = [0.6, 1.2]
        let v = UIView()
        v.layer.insertSublayer(gradientLayer, at: 0)
        return v
    }()
    
    private lazy var pausePlayButton: UIButton = {
        let btn = UIButton(type: .system)
        btn.setImage(UIImage(named: "pause"), for: .normal)
        btn.tintColor = .white
        btn.isHidden = true
        btn.translatesAutoresizingMaskIntoConstraints = false
        btn.addTarget(self, action: #selector(handlePause(_:)), for: .touchUpInside)
        return btn
    }()
    
    private lazy var currentTimeLabel: UILabel = {
        let lb = UILabel()
        lb.textColor = .white
        lb.font = UIFont.boldSystemFont(ofSize: 12)
        lb.translatesAutoresizingMaskIntoConstraints = false
        return lb
    }()
    
    private lazy var videoLengthLabel: UILabel = {
        let lb = UILabel()
        lb.textColor = .white
        lb.font = UIFont.boldSystemFont(ofSize: 12)
        lb.textAlignment = .right
        lb.translatesAutoresizingMaskIntoConstraints = false
        return lb
    }()
    
    private lazy var videoSlider: CustomSlider = {
        let sl = CustomSlider()
        sl.translatesAutoresizingMaskIntoConstraints = false
        sl.addTarget(self, action: #selector(handleSlider(_:)), for: .valueChanged)
        return sl
    }()
    
    // MARK: Properties
    var player: AVPlayer? {
        get { return playerLayer.player }
        set {
            playerLayer.player = newValue
            observePlayItemIsReady()
            setTotalLengthLabel()
            observeCurrentTime()
            observePlayerItemIsEnd()
        }
    }
    
    override class var layerClass: AnyClass {
        return AVPlayerLayer.self
    }
    
    private var playerLayer: AVPlayerLayer {
        return layer as! AVPlayerLayer
    }

    private var totalDuration: Float64? {
        guard let duration = player?.currentItem?.asset.duration else { return nil }
        return CMTimeGetSeconds(duration)
    }
    
    private var isEnd: Bool = false
    
    private var isPlaying: Bool {
        return player?.timeControlStatus == .playing
    }
    
    private var hasTappedToShowPlayBack: Bool = true
    private var timeObserver: Any?
    
    // MARK: Actions
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        handleTapOnPlayer()
    }
    
    @objc private func handleTapOnPlayer() {
        hasTappedToShowPlayBack ? showPlaybackControls() : hidePlaybackControls()
        hasTappedToShowPlayBack = !hasTappedToShowPlayBack
    }
    
    @objc private func handlePause(_ sender: UIButton) {
        if isPlaying {
            player?.pause()
            pausePlayButton.setImage(UIImage(named: "play"), for: .normal)
        } else {
            if isEnd {
                resetAndReplay()
                return
            }
            player?.play()
            pausePlayButton.setImage(UIImage(named: "pause"), for: .normal)
        }
    }
    
    private func resetAndReplay() {
        player?.seek(to: .zero, completionHandler: { [weak self] (_) in
            self?.player?.play()
            self?.pausePlayButton.setImage(UIImage(named: "pause"), for: .normal)
        })
        isEnd = false
    }
    
    @objc private func handleSlider(_ sender: UISlider) {
        guard let totalDuration = totalDuration else { return }
        let currentTime = sender.value * Float(totalDuration)
        let seekTime = CMTime(value: Int64(currentTime), timescale: 1)
        
        setCurrentTimeLabel(Int(currentTime))
        
        // it seeks more faster
        player?.seek(to: seekTime, toleranceBefore: .zero, toleranceAfter: .zero)
    }
    
    // MARK: Observers
    private var isInitial = true
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        
        if keyPath == #keyPath(AVPlayer.currentItem.loadedTimeRanges) {
            if isInitial {
                hidePlaybackControls()
                isInitial = false
            }
        }
    }
    
    private func observePlayItemIsReady() {
        player?.addObserver(self,
                            forKeyPath: #keyPath(AVPlayer.currentItem.loadedTimeRanges),
                            options: .new,
                            context: nil)
    }
    
    private func observeCurrentTime() {
        let interval = CMTime(seconds: 1/120, preferredTimescale: CMTimeScale(NSEC_PER_SEC))
        timeObserver = player?.addPeriodicTimeObserver(forInterval: interval, queue: DispatchQueue.main) { [weak self] (progressTime) in
            let progressSeconds = CMTimeGetSeconds(progressTime)
            self?.setCurrentTimeLabel(Int(progressSeconds))
            if let totalDuration = self?.totalDuration {
                let progressValue = progressSeconds / totalDuration
                self?.videoSlider.value = Float(progressValue)
            }
        }
    }
    
    private func observePlayerItemIsEnd() {
        NotificationCenter.default.addObserver(forName: .AVPlayerItemDidPlayToEndTime, object: nil, queue: nil) { [weak self] _ in
            self?.isEnd = true
            self?.pausePlayButton.setImage(UIImage(named: "play"), for: .normal)
        }
    }
    
    // Private Methods - Configure
    private func showPlaybackControls() {
        self.controlsContainerView.isHidden = false
        if !activityIndicatorView.isAnimating {
            pausePlayButton.isHidden = false
            let imageName = isPlaying ? "pause" : "play"
            pausePlayButton.setImage(UIImage(named: imageName), for: .normal)
        }
        videoSlider.showThumb()
    }
    
    private func hidePlaybackControls() {
        self.controlsContainerView.isHidden = true
        activityIndicatorView.isAnimating ? activityIndicatorView.stopAnimating() : nil
        pausePlayButton.isHidden = true
        videoSlider.hideThumb()
    }
    
    private func setCurrentTimeLabel(_ progressTime: Int) {
        let minutes = progressTime / 60
        let seconds = progressTime % 60
        let minutesString = String(format: "%02d", minutes)
        let secondsString = String(format: "%02d", seconds)
        if seconds >= 0 {
            currentTimeLabel.text = "\(minutesString):\(secondsString)"
        }
    }
    
    private func setTotalLengthLabel() {
        guard let totalDuration = totalDuration else { return }
        let totalSeconds = Int(totalDuration)
        let minutes = totalSeconds / 60
        let seconds = totalSeconds % 60
        let minutesInFormat = String(format: "%02d", minutes)
        let secondsInFormat = String(format: "%02d", seconds)
        videoLengthLabel.text = "\(minutesInFormat):\(secondsInFormat)"
    }
    
    // MARK: Life Cycle
    override func awakeFromNib() {
        super.awakeFromNib()
        
        addSubview(controlsContainerView)
        controlsContainerView.frame = self.frame
        
        controlsContainerView.addSubview(pausePlayButton)
        pausePlayButton.centerXAnchor.constraint(equalTo: controlsContainerView.centerXAnchor).isActive = true
        pausePlayButton.centerYAnchor.constraint(equalTo: controlsContainerView.centerYAnchor).isActive = true
        pausePlayButton.widthAnchor.constraint(equalToConstant: 40).isActive = true
        pausePlayButton.heightAnchor.constraint(equalToConstant: 40).isActive = true
        
        controlsContainerView.addSubview(activityIndicatorView)
        activityIndicatorView.centerXAnchor.constraint(equalTo: controlsContainerView.centerXAnchor).isActive = true
        activityIndicatorView.centerYAnchor.constraint(equalTo: controlsContainerView.centerYAnchor).isActive = true
        
        controlsContainerView.addSubview(currentTimeLabel)
        currentTimeLabel.leadingAnchor.constraint(equalTo: controlsContainerView.leadingAnchor, constant: 16).isActive = true
        currentTimeLabel.bottomAnchor.constraint(equalTo: controlsContainerView.bottomAnchor, constant: -14).isActive = true
        currentTimeLabel.widthAnchor.constraint(equalToConstant: 60).isActive = true
        currentTimeLabel.heightAnchor.constraint(equalToConstant: 24).isActive = true
        
        controlsContainerView.addSubview(videoLengthLabel)
        videoLengthLabel.trailingAnchor.constraint(equalTo: controlsContainerView.trailingAnchor, constant: -16).isActive = true
        videoLengthLabel.bottomAnchor.constraint(equalTo: controlsContainerView.bottomAnchor, constant: -14).isActive = true
        videoLengthLabel.widthAnchor.constraint(equalToConstant: 60).isActive = true
        videoLengthLabel.heightAnchor.constraint(equalToConstant: 24).isActive = true
        
        addSubview(videoSlider)
        videoSlider.leadingAnchor.constraint(equalTo: leadingAnchor).isActive = true
        videoSlider.trailingAnchor.constraint(equalTo: trailingAnchor).isActive = true
        videoSlider.topAnchor.constraint(equalTo: bottomAnchor).isActive = true
    }
    
    deinit {
        if let observer = timeObserver {
            player?.removeTimeObserver(observer)
        }
        player?.removeObserver(self, forKeyPath: #keyPath(AVPlayer.currentItem.loadedTimeRanges))
    }
}
