//
//  RefreshControl.swift
//  Turbolinks
//
//  Created by Domagoj Grizelj on 08/04/2019.
//  Copyright © 2019 Basecamp. All rights reserved.
//

import UIKit

public class RefreshControl: UIControl {
    open var isRefreshing: Bool = false
    
    func containtingScrollViewDidEndDragging(scrollView: UIScrollView, willDecelerate: Bool) {
        let minOffsetToTriggerRefresh: CGFloat = 50
        
        if (scrollView.contentOffset.y <= -minOffsetToTriggerRefresh) {
            if #available(iOS 10.0, *) {
                let impact = UIImpactFeedbackGenerator(style: UIImpactFeedbackGenerator.FeedbackStyle.light)
                impact.impactOccurred()
            } else {
                // Fallback on earlier versions
            }
            self.sendActions(for: .valueChanged)
        }
    }
    
    func beginRefreshing() {
        self.isRefreshing = true
    }
    
    func endRefreshing() {
        self.isRefreshing = false
    }
    
}
