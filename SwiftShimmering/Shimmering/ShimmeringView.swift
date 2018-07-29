//
//  ShimmeringView.swift
//  SwiftShimmering
//
//  Created by 林赟越 on 2018/7/26.
//  Copyright © 2018年 林赟越. All rights reserved.
//

import UIKit

public class ShimmeringView: UIView {
    public var contentView: UIView? {
        didSet {
            setContentView(oldValue)
        }
    }
    
    public override class var layerClass: AnyClass {
        return ShimmeringLayer.self
    }
    var shimmerLayer: ShimmeringLayer {
        return self.layer as! ShimmeringLayer
    }
    public override func layoutSubviews() {
        // Autolayout requires these to be set on the UIView, not the CALayer.
        // Do this *before* the layer has a chance to set the properties, as the
        // setters would be ignored (even for autolayout) if set to the same value.
        contentView?.bounds = self.bounds
        contentView?.center = self.center
        super.layoutSubviews()
    }
    func setContentView(_ oldValue: UIView?) {
        guard contentView !== oldValue else { return }
        guard let content = contentView else { return }
        if !self.subviews.contains(content) {
            self.addSubview(content)
        }
        shimmerLayer.contentLayer = content.layer
    }
}

extension ShimmeringView: Shimmering{
    public var shimmering: Bool {
        set {
            shimmerLayer.shimmering = newValue
        }
        get {
            return shimmerLayer.shimmering
        }
    }
    
    public var shimmeringPauseDuration: CFTimeInterval {
        set {
            shimmerLayer.shimmeringPauseDuration = newValue
        }
        get {
            return shimmerLayer.shimmeringPauseDuration
        }
    }
    
    public var shimmeringAnimationOpacity: CGFloat {
        set {
            shimmerLayer.shimmeringAnimationOpacity = newValue
        }
        get {
            return shimmerLayer.shimmeringAnimationOpacity
        }
    }
    
    public var shimmeringOpacity: CGFloat {
        set {
            shimmerLayer.shimmeringOpacity = newValue
        }
        get {
            return shimmerLayer.shimmeringOpacity
        }
    }
    
    public var shimmeringSpeed: CGFloat {
        set {
            shimmerLayer.shimmeringSpeed = newValue
        }
        get {
            return shimmerLayer.shimmeringSpeed
        }
    }
    
    public var shimmeringHighlightLength: CGFloat {
        set {
            shimmerLayer.shimmeringHighlightLength = newValue
        }
        get {
            return shimmerLayer.shimmeringHighlightLength
        }
    }
    
    public var shimmeringDirection: ShimmerDirection {
        set {
            shimmerLayer.shimmeringDirection = newValue
        }
        get {
            return shimmerLayer.shimmeringDirection
        }
    }
    
    public var shimmeringBeginFadeDuration: CFTimeInterval {
        set {
            shimmerLayer.shimmeringBeginFadeDuration = newValue
        }
        get {
            return shimmerLayer.shimmeringBeginFadeDuration
        }
    }
    
    public var shimmeringEndFadeDuration: CFTimeInterval {
        set {
            shimmerLayer.shimmeringEndFadeDuration = newValue
        }
        get {
            return shimmerLayer.shimmeringEndFadeDuration
        }
    }
    
    public var shimmeringFadeTime: CFTimeInterval {
        return shimmerLayer.shimmeringFadeTime
    }
    
    public var shimmeringBeginTime: CFTimeInterval {
        set {
            shimmerLayer.shimmeringBeginTime = newValue
        }
        get {
            return shimmerLayer.shimmeringBeginTime
        }
    }
    
    
}
