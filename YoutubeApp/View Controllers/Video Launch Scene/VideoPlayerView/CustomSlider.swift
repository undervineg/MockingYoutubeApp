//
//  CustomSlider.swift
//  YoutubeApp
//
//  Created by 심승민 on 11/03/2019.
//  Copyright © 2019 심승민. All rights reserved.
//

import UIKit

final class CustomSlider: UISlider {
    override init(frame: CGRect) {
        super.init(frame: frame)
        isContinuous = true
        configureThumb()
        configureTrack()
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        isContinuous = true
        configureThumb()
        configureTrack()
    }
    
    func showThumb() {
        configureThumb()
    }
    
    func hideThumb() {
        setThumbImage(UIImage(), for: .normal)
        setThumbImage(UIImage(), for: .highlighted)
    }
    
    // widen touch ranges
    override func point(inside point: CGPoint, with event: UIEvent?) -> Bool {
        var touchableBounds = self.bounds
        touchableBounds = touchableBounds.inset(by: UIEdgeInsets(top: -50, left: -10, bottom: -26, right: -10))
        return touchableBounds.contains(point)
    }
    
    override func trackRect(forBounds bounds: CGRect) -> CGRect {
        let newBounds = CGRect(origin: bounds.origin, size: CGSize(width: bounds.width, height: 2.5))
        return newBounds
    }
    
    private func configureThumb() {
        setThumbImage(UIImage(named: "thumb")?.withRenderingMode(.alwaysTemplate), for: .normal)
        setThumbImage(UIImage(named: "thumb_big")?.withRenderingMode(.alwaysTemplate), for: .highlighted)
        tintColor = .red
    }
    
    private func configureTrack() {
        minimumTrackTintColor = .red
        maximumTrackTintColor = .lightGray
    }
    
    private func sizedImage(image: UIImage, scaledToSize newSize: CGSize) -> UIImage? {
        UIGraphicsBeginImageContextWithOptions(newSize, false, 0.0);
        image.draw(in: CGRect(x: 0, y: 0, width: newSize.width, height: newSize.height))
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return newImage
    }
}
