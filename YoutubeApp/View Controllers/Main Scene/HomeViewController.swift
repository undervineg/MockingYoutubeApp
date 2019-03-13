//
//  HomeViewController.swift
//  YoutubeApp
//
//  Created by 심승민 on 10/03/2019.
//  Copyright © 2019 심승민. All rights reserved.
//

import UIKit

final class HomeViewController: UICollectionViewController {

    var videos: [Video] = [] {
        didSet {
            self.collectionView.reloadData()
        }
    }
    
    private let interactor = Interactor()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupCollectionView()
        
        fetchVideos()
    }
    
    private func fetchVideos() {
        ApiService.shared.fetchVideos { (videos) in
            self.videos = videos
        }
    }

    private func setupCollectionView() {
        collectionView.backgroundColor = .white
        
        let videoCellNib = UINib(nibName: String(describing: VideoCell.self), bundle: nil)
        self.collectionView.register(videoCellNib, forCellWithReuseIdentifier: VideoCell.reuseId)
    }
    
    // MARK: UICollectionViewDataSource

    override func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }


    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return videos.count
    }

    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: VideoCell.reuseId, for: indexPath) as! VideoCell
    
        let video = videos[indexPath.item]
        cell.configure(with: video)
        
        if let profileImageUrl = video.channel?.profileImageName {
            cell.profileImageView.loadImage(urlString: profileImageUrl)
        }
        
        if let thumbnailImageUrl = video.thumbnailImageName {
            cell.thumbnailImageView.loadImage(urlString: thumbnailImageUrl)
        }
    
        return cell
    }

}

extension HomeViewController {
    // MAKR: UICollectionViewDelegate
    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let videoLaunchPage = VideoLauncherViewController()
        videoLaunchPage.transitioningDelegate = self
        videoLaunchPage.interactor = interactor
        present(videoLaunchPage, animated: true)
    }
}

extension HomeViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: view.frame.width, height: 300)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 5
    }
}

extension HomeViewController: UIViewControllerTransitioningDelegate {
    func animationController(forDismissed dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        return SlideDownAnimator()
    }
    
    func interactionControllerForDismissal(using animator: UIViewControllerAnimatedTransitioning) -> UIViewControllerInteractiveTransitioning? {
        return interactor.hasStarted ? interactor : nil
    }
}
