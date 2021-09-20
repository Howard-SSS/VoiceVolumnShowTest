//
//  ViewController.swift
//  VoiceVolumnShowTest
//
//  Created by Howard on 2021/9/19.
//

import UIKit
import SnapKit

class ViewController: UIViewController {

    lazy var histogram: Histogram = {
        return Histogram(frame: CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: 47))
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.addSubview(histogram)
        histogram.snp.makeConstraints { make in
            make.left.right.centerX.centerY.equalToSuperview()
            make.height.equalTo(47)
        }
    }
}

