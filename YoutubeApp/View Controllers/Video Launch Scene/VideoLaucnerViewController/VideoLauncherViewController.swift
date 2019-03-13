//
//  VideoLauncherViewController.swift
//  YoutubeApp
//
//  Created by 심승민 on 11/03/2019.
//  Copyright © 2019 심승민. All rights reserved.
//

import UIKit
import AVFoundation

final class VideoLauncherViewController: UIViewController {
    // MARK: UI
    @IBOutlet weak var playerView: VideoPlayerView!
    
    // MARK: Properties
    var interactor: Interactor?
    
    // MARK: Life Cycle
    override var prefersStatusBarHidden: Bool {
        return true
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let panGesture = UIPanGestureRecognizer(target: self, action: #selector(draggingDownToDismiss(_:)))
        view.addGestureRecognizer(panGesture)
        
        fetchPlayerItems()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        play()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        pause()
    }
    
    // MARK: Actions
    func play() {
        playerView.player?.play()
    }
    
    func pause() {
        playerView.player?.pause()
    }
    
    @objc private func draggingDownToDismiss(_ gesture: UIPanGestureRecognizer) {
        let percentThreshold: CGFloat = 0.3
        
        let translation = gesture.translation(in: view)
        let verticalMovement = translation.y / view.bounds.height
        let downwardMovement = fmaxf(Float(verticalMovement), 0.0)
        let downwardMovementPercent = fminf(downwardMovement, 1.0)
        let progress = CGFloat(downwardMovementPercent)
        
        guard let interactor = interactor else { return }
        
        switch gesture.state {
        case .began:
            interactor.hasStarted = true
            dismiss(animated: true, completion: nil)
        case .changed:
            interactor.shouldFinish = progress > percentThreshold
            interactor.update(progress)
        case .cancelled:
            interactor.hasStarted = false
            interactor.cancel()
        case .ended:
            interactor.hasStarted = false
            interactor.shouldFinish == true ? interactor.finish() : interactor.cancel()
        default: break
        }
    }
    
    // MARK: Private Methods
    private func fetchPlayerItems() {
        if let videoURL = ApiService.shared.streamingSampleVideoURL() {
            playerView.player = AVPlayer(url: videoURL)
        }
    }

}
