//
//  Shimmering.swift
//  SwiftShimmering
//
//  Created by 林赟越 on 2018/7/26.
//  Copyright © 2018年 林赟越. All rights reserved.
//

import Foundation
import UIKit

public enum ShimmerDirection {
    //! Shimmer animation goes from left to right
    case ShimmerDirectionRight
    //! Shimmer animation goes from right to left
    case ShimmerDirectionLeft
    //! Shimmer animation goes from below to above
    case ShimmerDirectionUp
    //! Shimmer animation goes from above to below
    case ShimmerDirectionDown
}

public protocol Shimmering: NSObjectProtocol {
    //Set this to YES to start shimming and NO to stop. Defaults to NO.
    var shimmering: Bool { get set }
    
    //The time interval between shimmerings in seconds. Defaults to 0.4.
    var shimmeringPauseDuration: CFTimeInterval { get set }
    
    //The opacity of the content while it is shimmering. Defaults to 0.5.
    var shimmeringAnimationOpacity: CGFloat { get set }
    
    //The opacity of the content before it is shimmering. Defaults to 1.0.
    var shimmeringOpacity: CGFloat { get set }
    
    //The speed of shimmering, in points per second. Defaults to 230.
    var shimmeringSpeed: CGFloat { get set }
    
    //The highlight length of shimmering. Range of [0,1], defaults to 1.0.
    var shimmeringHighlightLength: CGFloat { get set }
    
    //The direction of shimmering animation. Defaults to Right.
    var shimmeringDirection: ShimmerDirection { get set }
    
    //The duration of the fade used when shimmer begins. Defaults to 0.1.
    var shimmeringBeginFadeDuration: CFTimeInterval { get set }
    
    //The duration of the fade used when shimmer ends. Defaults to 0.3.
    var shimmeringEndFadeDuration: CFTimeInterval { get set }
    
    /*
     The absolute CoreAnimation media time when the shimmer will fade in.
     Only valid after setting shimmering to NO.
     */
    var shimmeringFadeTime: CFTimeInterval { get }
    
    /*
     The absolute CoreAnimation media time when the shimmer will begin.
     Only valid after setting shimmering to YES.
     */
    var shimmeringBeginTime: CFTimeInterval { get set }
}
