//
//  SlideDownAnimator.swift
//  YoutubeApp
//
//  Created by 심승민 on 13/03/2019.
//  Copyright © 2019 심승민. All rights reserved.
//

import UIKit

final class SlideDownAnimator: NSObject, UIViewControllerAnimatedTransitioning {
    func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        return 0.6
    }
    
    func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        slideDownToDismiss(transitionContext)
    }
    
    private func slideDownToDismiss(_ transitionContext: UIViewControllerContextTransitioning) {
        guard
            let toVC = transitionContext.viewController(forKey: .to),
            let fromVC = transitionContext.viewController(forKey: .from) else { return }
        
        let containerView = transitionContext.containerView
        containerView.insertSubview(toVC.view, belowSubview: fromVC.view)
        
        let screenSize = UIScreen.main.bounds.size
        let bottomLeft = CGPoint(x: 0, y: screenSize.height)
        let finalFrame = CGRect(origin: bottomLeft, size: screenSize)
        
        UIView.animate(withDuration: transitionDuration(using: transitionContext), animations: {
            fromVC.view.frame = finalFrame
        }) { (_) in
            transitionContext.completeTransition(!transitionContext.transitionWasCancelled)
        }
    }
}
