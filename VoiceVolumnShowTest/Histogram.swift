//
//  Histogram.swift
//  VoiceVolumnShowTest
//
//  Created by Howard on 2021/9/19.
//

import Foundation
import UIKit

class Histogram: UIView {
    /// 音量最大
    var maxVolumn = 47
    /// 音量最小
    var minVolumn = 3
    /// 音量数组单元
    lazy var cellArray: [Float] = {
        var ret = [Float]()
        for _ in 1...20 * 5 {
            ret.append(Float(Int(arc4random()) % (maxVolumn - minVolumn) + minVolumn))
        }
        return ret
    }()
    /// 单元时间间隔
    var timeInterval: Double = 0.2
    /// 中线对应的音量下标
    var currentItemIndex: Int = 0
    /// 上次拖动位置
    var lastRect: CGPoint?
    /// 每个要画出单元之间的间隔
    let interval: Int = 3
    /// 屏幕能容纳的单元数量
    lazy var widthNum = {
        return Int(frame.width) / (interval + 1) + (Int(frame.width) % (interval + 1) > 0 ? 1: 0)
    }()
    /// 开始展示的单元下表
    var fromCellIndex: Int = 0
    /// 展示的范围,可以配合 fromCellIndex 计算到结束单元
    lazy var range: Int = {
        return cellArray.count < widthNum ? cellArray.count : widthNum
    }()
    /// 数据是否有效,包括cellArray.currentItemIndex,currentItemX,fromCellIndex,range
    var dataValid = true
    /// 是否有中线
    var haveMiddleLine = true
            
    let middleLineColor = UIColor(hexString: "F10D0D", alphaPercent: 85)
        
    let volumnLineColor1 = UIColor(hexString: "F10D0D")
    
    let volumnLineColor2 = UIColor(hexString: "161616")
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        contentMode = .redraw
        isUserInteractionEnabled = true
        backgroundColor = UIColor(hexString: "666666", alphaPercent: 5)
        NotificationCenter.default.addObserver(self, selector: #selector(updateView1(notice:)), name: NSNotification.Name.init("panMeters"), object: nil)
        addGesture()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    @objc func updateView1(notice: Notification) {
        setNeedsDisplay()
    }
    
    override func draw(_ rect: CGRect) {
        if !dataValid {
            return
        }
        // 居中偏移
        var offset: CGFloat = 0
        if cellArray.count < widthNum {
            offset = (frame.width - CGFloat(cellArray.count * (interval + 1))) / 2
        }
        if cellArray.count > 0 {
            let context = UIGraphicsGetCurrentContext()
            context?.setLineWidth(1)
            context?.setStrokeColor(volumnLineColor1.cgColor)
            for index in fromCellIndex...currentItemIndex {
                let x = CGFloat((index - fromCellIndex) * (interval + 1) + 1) + offset
                context?.move(to: CGPoint(x: x, y: rect.midY))
                context?.addLine(to: CGPoint(x: x, y: rect.midY - CGFloat(cellArray[index] / 2)))
                context?.addLine(to: CGPoint(x: x, y: rect.midY + CGFloat(cellArray[index] / 2)))
            }
            context?.strokePath()
            if currentItemIndex <= fromCellIndex + range - 1{
                context?.setStrokeColor(volumnLineColor2.cgColor)
                for index in currentItemIndex...fromCellIndex + range - 1 {
                    let x = CGFloat((index - fromCellIndex) * (interval + 1) + 1) + offset
                    context?.move(to: CGPoint(x: x, y: rect.midY))
                    context?.addLine(to: CGPoint(x: x, y: rect.midY - CGFloat(cellArray[index] / 2)))
                    context?.addLine(to: CGPoint(x: x, y: rect.midY + CGFloat(cellArray[index] / 2)))
                }
                context?.strokePath()
            }
            if haveMiddleLine {
                context?.setLineWidth(2)
                context?.setStrokeColor(middleLineColor.cgColor)
                let x = CGFloat((currentItemIndex - fromCellIndex) * (interval + 1) + 1) + offset
                context?.move(to: CGPoint(x: x, y: 0))
                context?.addLine(to: CGPoint(x: x, y: rect.height))
                context?.strokePath()
            }
            
        }
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        lastRect = nil
    }

    func addGesture() {
        let pan = UIPanGestureRecognizer(target: self, action: #selector(panGesture(gesture:)))
        pan.cancelsTouchesInView = false
        addGestureRecognizer(pan)
    }
    /// 右移offset各单元
    func moveRight(offset: Int) {
        currentItemIndex += offset
        currentItemIndex = min(currentItemIndex, cellArray.count - 1)
        if currentItemIndex > (range - 1) / 2 && currentItemIndex < cellArray.count - 1 - ((range - 1) / 2) {
            fromCellIndex += offset
            fromCellIndex = min(fromCellIndex, cellArray.count - 1 - range)
        }
    }
    /// 左移offset各单元
    func moveLeft(offset: Int) {
        currentItemIndex -= offset
        currentItemIndex = max(currentItemIndex, 0)
        if currentItemIndex > (range - 1) / 2 && currentItemIndex < cellArray.count - 1 - ((range - 1) / 2) {
            fromCellIndex -= offset
            fromCellIndex = max(fromCellIndex, 0)
        }
    }
    @objc func panGesture(gesture: UIPanGestureRecognizer) {
        if !dataValid {
            return
        }
        if lastRect != nil {
            if gesture.location(in: self).x > lastRect!.x {
                // 向右
                let offset = Int(gesture.location(in: self).x - lastRect!.x) / (interval + 1)
                moveRight(offset: offset)
            } else if gesture.location(in: self).x < lastRect!.x {
                // 向左
                let offset = Int(lastRect!.x - gesture.location(in: self).x) / (interval + 1)
                moveLeft(offset: offset)
            }
        }
        self.lastRect = gesture.location(in: self)
        NotificationCenter.default.post(name: NSNotification.Name.init("panMeters"), object: nil)
    }
    
    func t() {
        Timer.scheduledTimer(withTimeInterval: timeInterval, repeats: true) { timer in
            if self.currentItemIndex == self.cellArray.count - 1 {
                timer.invalidate()
                return
            }
            self.moveRight(offset: 1)
            NotificationCenter.default.post(name: NSNotification.Name.init("panMeters"), object: nil)

        }
    }
}
