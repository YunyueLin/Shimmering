//
//  ShimmeringLayer.swift
//  SwiftShimmering
//
//  Created by 林赟越 on 2018/7/26.
//  Copyright © 2018年 林赟越. All rights reserved.
//

import UIKit
import QuartzCore

public let ShimmerDefaultBeginTime = Double.greatestFiniteMagnitude

extension CAAnimation {
    // take a shimmer slide animation and turns into finish
    func shimmer_slide_finish() -> CAAnimation{
        let anim = self.copy() as! CAAnimation
        anim.repeatCount = 0
        return anim
    }
    
    // take a shimmer slide animation and turns into repeating
    func shimmer_slide_repeat(duration: CFTimeInterval, direction: ShimmerDirection) -> CAAnimation{
        let anim = self.copy() as! CAAnimation
        anim.repeatCount = .greatestFiniteMagnitude
        anim.duration = duration
        switch direction {
        case .ShimmerDirectionRight,.ShimmerDirectionDown:
            anim.speed = fabsf(anim.speed)
        default:
            anim.speed = -fabs(anim.speed)
        }
        return anim
    }
    
    static func fade_animation(layer: CALayer, opacity: CGFloat, duration: CFTimeInterval) -> CABasicAnimation{
        let animation = CABasicAnimation(keyPath: "opacity")
        if layer.presentation() == nil {
            animation.fromValue = layer.opacity
        }
        animation.toValue = opacity
        animation.fillMode = kCAFillModeBoth
        animation.isRemovedOnCompletion = false
        animation.duration = duration
        return animation
    }
    
    static func shimmer_slide_animation(duration: CFTimeInterval, direction: ShimmerDirection) -> CABasicAnimation{
        let animation = CABasicAnimation(keyPath: "position")
        animation.toValue = NSValue(cgPoint: .zero)
        animation.duration = duration
        animation.repeatCount = .greatestFiniteMagnitude
        switch direction {
        case .ShimmerDirectionLeft,.ShimmerDirectionUp:
            animation.speed = -fabsf(animation.speed)
        default:
            break
        }
        return animation
    }
}

public class ShimmeringLayer:CALayer, CALayerDelegate,CAAnimationDelegate,Shimmering{
    //animations keys
    let kShimmerSlideAnimation = "slide"
    let kShimmerFadeAnimation = "fade"
    let kShimmerEndFadeAnimation = "fade-end"
    
    public override init() {
        // default configuration
        shimmeringPauseDuration = 0.4
        shimmeringSpeed = 230.0
        shimmeringHighlightLength = 1.0
        shimmeringAnimationOpacity = 0.5
        shimmeringOpacity = 1.0
        shimmeringDirection = .ShimmerDirectionRight
        shimmeringBeginFadeDuration = 0.1
        shimmeringEndFadeDuration = 0.3
        shimmeringBeginTime = ShimmerDefaultBeginTime
        maskLayer = nil
        contentLayer = nil
        shimmering = false
        _shimmeringFadeTime = 0
        super.init()
    }
    
    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override public func layoutSublayers() {
        super.layoutSublayers()
        let r = self.bounds
        contentLayer?.anchorPoint = .init(x: 0.5, y: 0.5)
        contentLayer?.bounds = r
        contentLayer?.position = .init(x: r.midX, y: r.midY)
        if maskLayer != nil {
            self.updateMaskLayout()
        }
    }
    
    // MARK: Internal
    func clearMask() {
        guard maskLayer != nil else { return }
        let disableActions = CATransaction.disableActions()
        CATransaction.setDisableActions(true)
        self.maskLayer = nil
        contentLayer?.mask = nil
        CATransaction
            .setDisableActions(disableActions)
    }
    
    func createMaskIfNeeded() {
        if shimmering && maskLayer == nil {
            maskLayer = ShimmeringMaskLayer()
            maskLayer?.delegate = self
            contentLayer?.mask = maskLayer
            self.updateMaskColors()
            self.updateMaskLayout()
        }
    }
    
    func updateMaskColors() {
        guard let maskLayer = maskLayer else { return }
        // We create a gradient to be used as a mask.
        // In a mask, the colors do not matter, it's the alpha that decides the degree of masking.
        let maskedColor = UIColor(white: 1, alpha: shimmeringOpacity)
        let unmaskedColor = UIColor(white: 1, alpha: shimmeringAnimationOpacity)
        // Create a gradient from masked to unmasked to masked.
        maskLayer.colors = [
            maskedColor.cgColor,
            unmaskedColor.cgColor,
            maskedColor.cgColor
        ]
    }
    
    func updateMaskLayout() {
        guard let contentLayer = contentLayer else { return }
        guard let maskLayer = maskLayer else { return }
        // Everything outside the mask layer is hidden, so we need to create a mask long enough for the shimmered layer to be always covered by the mask.
        var length: CGFloat = 0
        let contentHeight = contentLayer.bounds.height
        let contentWidth = contentLayer.bounds.width
        switch shimmeringDirection {
        case .ShimmerDirectionDown,.ShimmerDirectionUp:
            length = contentHeight
        case .ShimmerDirectionLeft,.ShimmerDirectionRight:
            length = contentWidth
        }
        // extra distance for the gradient to travel during the pause.
        let extraDistance: CGFloat = length + shimmeringSpeed * CGFloat(shimmeringPauseDuration)
        
        // compute how far the shimmering goes
        let fullShimmerLength: CGFloat = length * 3.0 + extraDistance
        let travelDistance: CGFloat = length * 2 + extraDistance
        
        // position the gradient for the desired width
        let highlightOutsideLength: CGFloat = (1 - shimmeringHighlightLength) / 2
        let locs = [
            highlightOutsideLength,
            0.5,
            1 - highlightOutsideLength
        ]
        maskLayer.locations = locs.map { value in
            return NSNumber(value: Double(value))
        }
        let startPoint: CGFloat = (length + extraDistance) / fullShimmerLength
        let endPoint: CGFloat = travelDistance / fullShimmerLength
        
        // position for the start of the animation
        maskLayer.anchorPoint = .zero
        switch shimmeringDirection {
        case .ShimmerDirectionDown,.ShimmerDirectionUp:
            maskLayer.startPoint = .init(x: 0, y: startPoint)
            maskLayer.endPoint = .init(x: 0, y: endPoint)
            maskLayer.position = .init(x: 0, y: -travelDistance)
            maskLayer.bounds = .init(x: 0, y: 0, width: contentWidth, height: fullShimmerLength)
        case .ShimmerDirectionLeft,.ShimmerDirectionRight:
            maskLayer.startPoint = .init(x: startPoint, y: 0)
            maskLayer.endPoint = .init(x: endPoint, y: 0)
            maskLayer.position = .init(x: -travelDistance, y: 0)
            maskLayer.bounds = .init(x: 0, y: 0, width: fullShimmerLength, height: contentHeight)
        }
    }
    
    func updateShimmering() {
        // create mask if needed
        self.createMaskIfNeeded()
        
        // if not shimmering and no mask, noop
        if shimmering == false && maskLayer == nil { return }
        guard let maskLayer = maskLayer else {
            shimmering = false
            return
        }
        guard let contentLayer = contentLayer else {
            shimmering = false
            return
        }
        let contentHeight = contentLayer.bounds.height
        let contentWidth = contentLayer.bounds.width
        
        // ensure layout
        self.layoutIfNeeded()
        let disableActions = CATransaction.disableActions()
        if !shimmering {
            if disableActions {
                // simply remove mask
                self.clearMask()
            } else {
                // end slide
                var slideEndTime: CFTimeInterval = 0
                if let slideAnimation = maskLayer.animation(forKey: kShimmerSlideAnimation) {
                    // determine total time sliding
                    let now = CACurrentMediaTime()
                    let slideTotalDuration = now - slideAnimation.beginTime
                    // determine time offset into current slide
                    let slideTimeOffset = fmod(slideTotalDuration,slideAnimation.duration)
                    // transition to non-repeating slide
                    let finishAnimation = slideAnimation.shimmer_slide_finish()
                    // adjust begin time to now - offset
                    finishAnimation.beginTime = now - slideTimeOffset
                    // note slide end time and begin
                    slideEndTime = finishAnimation.beginTime + slideAnimation.duration
                    maskLayer.add(finishAnimation, forKey: kShimmerSlideAnimation)
                }
                // fade in text at slideEndTime
                isEndingFade = true
                let fadeInAnimation = CAAnimation.fade_animation(layer: maskLayer.fadeLayer, opacity: 1, duration: shimmeringEndFadeDuration)
                fadeInAnimation.delegate = self
                fadeInAnimation.setValue(true, forKey: kShimmerEndFadeAnimation)
                fadeInAnimation.beginTime = slideEndTime
                maskLayer.fadeLayer
                    .add(fadeInAnimation, forKey: kShimmerFadeAnimation)
                // expose end time for synchronization
                _shimmeringFadeTime = slideEndTime
            }
        } else {
            // fade out text, optionally animated
            var fadeOutAnimation: CABasicAnimation?
            if shimmeringBeginFadeDuration > 0 && !disableActions {
                fadeOutAnimation = CAAnimation.fade_animation(layer: maskLayer.fadeLayer, opacity: 0, duration: shimmeringBeginFadeDuration)
                maskLayer.fadeLayer.add(fadeOutAnimation!, forKey: kShimmerFadeAnimation)
            } else {
                let innerDisableActions = CATransaction.disableActions()
                CATransaction.setDisableActions(true)
                maskLayer.fadeLayer.opacity = 0
                maskLayer.fadeLayer.removeAllAnimations()
                CATransaction.setDisableActions(innerDisableActions)
            }
            // compute shimmer duration
            var length: CGFloat = 0
            switch shimmeringDirection {
            case .ShimmerDirectionDown,.ShimmerDirectionUp:
                length = contentHeight
            case .ShimmerDirectionLeft,.ShimmerDirectionRight:
                length = contentWidth
            }
            let animationDuration: CFTimeInterval = Double(length / shimmeringSpeed) + shimmeringPauseDuration
            if let slideAnimation = maskLayer.animation(forKey: kShimmerSlideAnimation) {
                // ensure existing slide animation repeats
                maskLayer.add(slideAnimation, forKey: kShimmerSlideAnimation)
            } else {
                // add slide animation
                let animation = CAAnimation.shimmer_slide_animation(duration: animationDuration, direction: shimmeringDirection)
                animation.fillMode = kCAFillModeForwards
                animation.isRemovedOnCompletion = false
                if shimmeringBeginTime == ShimmerDefaultBeginTime {
                    shimmeringBeginTime = CACurrentMediaTime() + (fadeOutAnimation?.duration ?? 0)
                }
                animation.beginTime = shimmeringBeginTime
                maskLayer.add(animation, forKey: kShimmerSlideAnimation)
            }
        }
    }
    
    // MARK: CALayerDelegate
    public func action(for layer: CALayer, forKey event: String) -> CAAction? {
        // no associated actions
        return nil
    }
    
    // MARK: CAAnimationDelegate
    public func animationDidStop(_ anim: CAAnimation, finished flag: Bool) {
        guard let endFade = anim.value(forKey: kShimmerEndFadeAnimation) as? Bool else { return }
        if flag && endFade {
            maskLayer?.fadeLayer
                .removeAnimation(forKey: kShimmerFadeAnimation)
            self.clearMask()
            isEndingFade = false
        }
    }
    
    //MARK: Properties
    var maskLayer: ShimmeringMaskLayer?
    public var contentLayer: CALayer? {
        didSet {
            setContentLayer(oldValue)
        }
    }
    
    public var shimmering: Bool {
        didSet {
            setShimmering(oldValue)
        }
    }
    
    public var shimmeringPauseDuration: CFTimeInterval {
        didSet {
            setShimmeringPauseDuration(oldValue)
        }
    }
    
    public var shimmeringAnimationOpacity: CGFloat {
        didSet {
            setShimmeringAnimationOpacity(oldValue)
        }
    }
    
    public var shimmeringOpacity: CGFloat {
        didSet {
            setShimmeringOpacity(oldValue)
        }
    }
    
    public var shimmeringSpeed: CGFloat {
        didSet {
            setShimmeringSpeed(oldValue)
        }
    }
    
    public var shimmeringHighlightLength: CGFloat {
        didSet {
            setShimmeringHighlightLength(oldValue)
        }
    }
    
    public var shimmeringDirection: ShimmerDirection {
        didSet {
            setShimmeringDirection(oldValue)
        }
    }
    
    public var shimmeringBeginFadeDuration: CFTimeInterval {
        didSet {
            setShimmeringBeginFadeDuration(oldValue)
        }
    }
    
    public var shimmeringEndFadeDuration: CFTimeInterval {
        didSet {
            setShimmeringEndFadeDuration(oldValue)
        }
    }
    
    private var _shimmeringFadeTime: CFTimeInterval
    public var shimmeringFadeTime: CFTimeInterval {
        return _shimmeringFadeTime
    }
    
    public var shimmeringBeginTime: CFTimeInterval {
        didSet {
            setShimmeringBeginTime(oldValue)
        }
    }
    
    public override var bounds: CGRect {
        didSet {
            setBounds(oldValue)
        }
    }
    
    private var isEndingFade: Bool = false {
        didSet {
            if shimmering {
                self.updateShimmering()
            }
        }
    }
    
    func setContentLayer(_ oldValue: CALayer?) {
        guard contentLayer !== oldValue else { return }
        // reset mask
        self.maskLayer = nil
        // note content layer and add for display
        if let contentLayer = contentLayer {
            self.sublayers = [contentLayer]
        } else {
            self.sublayers = nil
        }
        // update shimmering animation
        self.updateShimmering()
    }
    
    func setShimmering(_ oldValue: Bool) {
        guard shimmering != oldValue else { return }
        guard !isEndingFade else { return }
        self.updateShimmering()
    }
    
    func setShimmeringSpeed(_ oldValue: CGFloat) {
        guard shimmeringSpeed != oldValue else { return }
        self.updateShimmering()
    }
    
    func setShimmeringHighlightLength(_ oldValue: CGFloat) {
        guard shimmeringHighlightLength != oldValue else { return }
        self.updateShimmering()
    }
    
    func setShimmeringDirection(_ oldValue: ShimmerDirection) {
        guard shimmeringDirection != oldValue else { return }
        self.updateShimmering()
    }
    
    func setShimmeringPauseDuration(_ oldValue: CFTimeInterval) {
        guard shimmeringPauseDuration != oldValue else { return }
        self.updateShimmering()
    }
    
    func setShimmeringAnimationOpacity(_ oldValue: CGFloat) {
        guard shimmeringAnimationOpacity != oldValue else { return }
        self.updateMaskColors()
    }
    
    func setShimmeringOpacity(_ oldValue: CGFloat) {
        guard shimmeringOpacity != oldValue else { return }
        self.updateMaskColors()
    }
    
    func setShimmeringBeginTime(_ oldValue: CFTimeInterval) {
        guard shimmeringBeginTime != oldValue else { return }
        self.updateShimmering()
    }
    
    func setShimmeringBeginFadeDuration(_ oldValue: CFTimeInterval) {
        guard shimmeringBeginFadeDuration != oldValue else { return }
        self.updateShimmering()
    }
    
    func setShimmeringEndFadeDuration(_ oldValue: CFTimeInterval) {
        guard shimmeringEndFadeDuration != oldValue else { return }
        self.updateShimmering()
    }
    
    func setBounds(_ oldValue: CGRect) {
        guard oldValue.equalTo(self.bounds) else { return }
        self.updateShimmering()
    }
}
