//
//  ViewController.swift
//  SwiftShimmering
//
//  Created by 林赟越 on 2018/7/26.
//  Copyright © 2018年 林赟越. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
//        view.backgroundColor = UIColor.init(white: 0, alpha: 0.8)
        
        shimmeringView.backgroundColor = .black
        loadingLabel.textColor = .white
        shimmeringView.contentView = loadingLabel
        shimmeringView.shimmering = true
        
        
        let shimmeringV2 = ShimmeringView.init(frame: CGRect(x: 0, y: 200, width: 200, height: 200))
        view.addSubview(shimmeringV2)
        
        let label2 = UILabel.init(frame: shimmeringV2.bounds)
        shimmeringV2.addSubview(label2)
        label2.textColor = .white
        label2.text = "使用代码添加"
        
        shimmeringV2.contentView = label2
        shimmeringV2.shimmering = true
        
    }
    
    
    @IBOutlet weak var shimmeringView: ShimmeringView!
    @IBOutlet weak var loadingLabel: UILabel!
    
}

