//
//  VideoCell.swift
//  YoutubeApp
//
//  Created by 심승민 on 10/03/2019.
//  Copyright © 2019 심승민. All rights reserved.
//

import UIKit

final class VideoCell: UICollectionViewCell {

    static let reuseId = "VideoCell"
    
    @IBOutlet weak var thumbnailImageView: LoadableImageView!
    @IBOutlet weak var profileImageView: LoadableImageView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var subtitleTextView: UITextView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        profileImageView.layer.cornerRadius = profileImageView.frame.height / 2
        profileImageView.layer.masksToBounds = true
        subtitleTextView.textContainerInset = UIEdgeInsets(top: 0, left: -4, bottom: 0, right: 0)
        subtitleTextView.isScrollEnabled = false
    }

    func configure(with video: Video) {
        titleLabel.text = video.title
        
        if let channelName = video.channel?.name, let numberOfViews = video.numberOfViews {
            let numberFormatter = NumberFormatter()
            numberFormatter.numberStyle = .decimal
            
            subtitleTextView.text = "\(channelName) • 조회수 \(numberFormatter.string(from: NSNumber(value: numberOfViews))!) • 1주 전"
        }
    }
}
