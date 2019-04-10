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
        let minOffsetToTriggerRefresh: CGFloat = 100
        self.handleScroll(scrollView: scrollView)
        
        if (scrollView.contentOffset.y <= -minOffsetToTriggerRefresh) {
            if #available(iOS 10.0, *) {
                let impact = UIImpactFeedbackGenerator(style: UIImpactFeedbackGenerator.FeedbackStyle.light)
                impact.impactOccurred()
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.7, execute: {
                self.sendActions(for: .valueChanged)
            })
        }
    }
    
    func containtingScrollViewDidScroll(scrollView: UIScrollView) {
        self.constraintToParent?.constant = scrollView.contentOffset.y + 45
        self.handleScroll(scrollView: scrollView)
    }
    
    public var radius: CGFloat = 15
    public var fillColor: UIColor = .red
    public var innerCircleColor: UIColor = UIColor(red:0.40, green:0.40, blue:0.40, alpha:1.0)
    public var circleWidth: CGFloat = 2
    public var requiredDraggingOffset: CGFloat = -100.0
    public var hideAnimationDuration: TimeInterval = 0.2
    
    private var constraintToParent: NSLayoutConstraint?
    private var circleLayer: CAShapeLayer = CAShapeLayer()
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
        translatesAutoresizingMaskIntoConstraints = false
        setupBasicAppearance()
    }
    
    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    public func add(to view: UIView) {
        view.addSubview(self)
        
        setupBasicAppearance()
        
        createSizeConstraints()
        createConstraints(to: view)
        
        setupCircleLayer()
    }
    
    private func setupBasicAppearance() {
        self.backgroundColor = .clear
        self.layer.cornerRadius = radius

    }
    
    private func setupCircleLayer() {
        let arcCenter = CGPoint(x: frame.size.width / 2,
                                y: frame.size.height / 2)
        let circlePath = UIBezierPath(arcCenter: arcCenter,
                                      radius: radius - circleWidth,
                                      startAngle: -.pi / 2,
                                      endAngle: .pi * 2,
                                      clockwise: true)
        
        circleLayer.path = circlePath.cgPath
        circleLayer.fillColor = UIColor.clear.cgColor
        circleLayer.strokeColor = innerCircleColor.cgColor
        circleLayer.lineWidth = circleWidth
        
        circleLayer.strokeEnd = 0.0
        
        layer.addSublayer(circleLayer)

//        self.transform = CGAffineTransform(scaleX: 0, y: 0)

    }
    
    private func createConstraints(to view: UIView) {
        let topConstraint = NSLayoutConstraint(item: self,
                                               attribute: .top,
                                               relatedBy: .equal,
                                               toItem: view,
                                               attribute: .top,
                                               multiplier: 1.0,
                                               constant: 0)
        
        let centerConstraint = NSLayoutConstraint(item: self,
                                                  attribute: .centerX,
                                                  relatedBy: .equal,
                                                  toItem: view,
                                                  attribute: .centerX,
                                                  multiplier: 1.0,
                                                  constant: 0.0)
        self.constraintToParent = topConstraint
        view.addConstraints([topConstraint, centerConstraint])
        self.layoutIfNeeded()
    }
    
    private func createSizeConstraints() {
        let heightConstraint = NSLayoutConstraint(item: self,
                                                  attribute: .height,
                                                  relatedBy: .equal,
                                                  toItem: nil,
                                                  attribute: .notAnAttribute,
                                                  multiplier: 0.0,
                                                  constant: radius * 2)
        let widthConstraint = NSLayoutConstraint(item: self,
                                                 attribute: .width,
                                                 relatedBy: .equal,
                                                 toItem: self,
                                                 attribute: .height,
                                                 multiplier: 1.0,
                                                 constant: 0.0)
        self.addConstraints([heightConstraint, widthConstraint])
        self.layoutIfNeeded()
    }
    
    
    private func handleScroll(scrollView: UIScrollView) {
        let translation = scrollView.contentOffset
        guard !self.isRefreshing else { return }
        
        if translation.y <= 0 && translation.y > -100 {
//            self.transform = CGAffineTransform(scaleX: -translation.y / 100, y: -translation.y / 100)
        } else if translation.y > 0 {
//            self.transform = CGAffineTransform(scaleX: 0, y: 0)
        }
        
        if translation.y <= 0 && translation.y > -100 {
            let progress = translation.y / requiredDraggingOffset
            print(progress)
            circleLayer.strokeEnd = progress
            
            superview?.layoutIfNeeded()
            print(translation.y)
        }
        
        if translation.y < requiredDraggingOffset {
            let x = scrollView.panGestureRecognizer.state
            if x == .ended {
                beginRefreshing()
            }
        }
    }
    
    public func endRefreshing() {
        isRefreshing = false
        
        stopRotating()
        animateCircle(to: 0.0)
        
        UIView.animate(withDuration: hideAnimationDuration, animations: {
//            self.transform = CGAffineTransform(scaleX: 0.01, y: 0.01)
        }) { (Bool) in
//            self.transform = CGAffineTransform(scaleX: 0, y: 0)

        }
    }
    
    public func beginRefreshing() {
        isRefreshing = true
        
        circleLayer.strokeEnd = 0.5
        startRotating()
    }
    
    private func animateCircle(to progress: CGFloat) {
        let animation = CABasicAnimation(keyPath: "strokeEnd")
        
        animation.duration = hideAnimationDuration / 2
        animation.fromValue = circleLayer.strokeEnd
        animation.toValue = progress
        
        circleLayer.strokeEnd = 0.0
        
        animation.timingFunction = CAMediaTimingFunction(name: CAMediaTimingFunctionName.easeInEaseOut)
        
        circleLayer.add(animation, forKey: UIView.kProgressAnimationKey)
    }
    
    
    private func startRotating() {
        let rotationAnimation = CABasicAnimation(keyPath: "transform.rotation.z")
        
        rotationAnimation.fromValue = 0.0
        rotationAnimation.toValue = Float.pi * 2
        rotationAnimation.duration = 1.0
        rotationAnimation.repeatCount = .infinity
        
        self.layer.add(rotationAnimation, forKey: UIView.kRotationAnimationKey)
    }
    
    
    private func stopRotating() {
        guard layer.animation(forKey: UIView.kRotationAnimationKey) != nil else { return }
        layer.removeAnimation(forKey: UIView.kRotationAnimationKey)
    }
}

extension UIView {
    public static let kRotationAnimationKey = "rotationAnimation"
    public static let kProgressAnimationKey = "progressAnimation"
}
