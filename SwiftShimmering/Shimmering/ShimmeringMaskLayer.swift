//
//  ShimmeringMaskLayer.swift
//  SwiftShimmering
//
//  Created by 林赟越 on 2018/7/26.
//  Copyright © 2018年 林赟越. All rights reserved.
//

import UIKit

class ShimmeringMaskLayer: CAGradientLayer {
    var fadeLayer : CALayer
    
    override init() {
        fadeLayer = CALayer()
        fadeLayer.backgroundColor = UIColor.white.cgColor
        super.init()
        addSublayer(fadeLayer)
    }
    
    override func layoutSublayers() {
        super.layoutSublayers()
        let r = self.bounds
        fadeLayer.bounds = r
        fadeLayer.position = .init(x: r.midX, y: r.midY)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
