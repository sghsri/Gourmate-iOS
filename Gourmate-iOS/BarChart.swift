//
//  BarChart.swift
//  Gourmate-iOS
//
//  Created by Matthew Onghai on 7/5/20.
//  Copyright © 2020 utexas. All rights reserved.
//

import Foundation
import UIKit

struct BarEntry {
   let score: Int
   let title: String
}

class BarChartView: UIView {
  
    private let mainLayer: CALayer = CALayer()
    private let scrollView: UIScrollView = UIScrollView()
    let space: CGFloat = 20.0
    let barHeight: CGFloat = 20.0
    let contentSpace: CGFloat = 44.0
    var maxBarLength: Int = 100
    
    var dataEntries: [BarEntry] = [] {
    didSet {
       mainLayer.sublayers?.forEach({$0.removeFromSuperlayer()})
       scrollView.contentSize = CGSize(width: frame.size.width, height:
       barHeight + space * CGFloat(dataEntries.count) + contentSpace)
       mainLayer.frame = CGRect(x: 0, y: 0, width:
       scrollView.contentSize.width, height:
       scrollView.contentSize.height)
       for i in 0..<dataEntries.count {
          showEntry(index: i, entry: dataEntries[i])
       }
    }
    }
    override init(frame: CGRect) {
       super.init(frame: frame)
       setupView()
    }
    required init?(coder aDecoder: NSCoder) {
       fatalError("init(coder:) has not been implemented")
    }
    private func setupView() {
       scrollView.layer.addSublayer(mainLayer)
       addSubview(scrollView)
    }
    override func layoutSubviews() {
       scrollView.frame = CGRect(x: 0, y: 0, width: frame.size.width,
       height: frame.size.height)
    }
    
    private func showEntry(index: Int, entry: BarEntry) {
        let xPos: CGFloat = translateWidthValueToXPosition(value:
        Float(entry.score) / Float(maxBarLength))
        let yPos: CGFloat = space + CGFloat(index) * (barHeight + space)
        drawBar(xPos: xPos, yPos: yPos, index: index)
        drawTextValue(xPos: 16.0 + 300, yPos: yPos + 2.0, textValue: "\(entry.score)")
        drawTitle(xPos: 16.0, yPos: yPos + 4.0, width: 150.0, height: 20.0, title: entry.title)
    }
    
    private func drawBar(xPos: CGFloat, yPos: CGFloat, index: Int) {
        let barLayer = CALayer()
        barLayer.frame = CGRect(x: 80.0, y: yPos, width: xPos, height: 20.0)
        
        barLayer.backgroundColor = Bool(index % 2 as NSNumber) ? UIColor.systemRed.cgColor : UIColor.systemYellow.cgColor
        mainLayer.addSublayer(barLayer)
    }
    
    private func drawTextValue(xPos: CGFloat, yPos: CGFloat, textValue: String) {
       let textLayer = CATextLayer()
       textLayer.frame = CGRect(x: xPos, y: yPos, width: 33, height: 80.0)
       textLayer.foregroundColor = UIColor.black.cgColor
       textLayer.backgroundColor = UIColor.clear.cgColor
       textLayer.alignmentMode = CATextLayerAlignmentMode.center
       textLayer.contentsScale = UIScreen.main.scale
       textLayer.font = CTFontCreateWithName(UIFont.systemFont(ofSize: 14.0).fontName as CFString, 0, nil)
       textLayer.fontSize = 14
       textLayer.string = textValue
       mainLayer.addSublayer(textLayer)
    }
    
    private func drawTitle(xPos: CGFloat, yPos: CGFloat, width: CGFloat, height: CGFloat = 22, title: String) {
       let textLayer = CATextLayer()
       textLayer.frame = CGRect(x: xPos, y: yPos, width: width, height: height)
       textLayer.foregroundColor = UIColor.black.cgColor
       textLayer.backgroundColor = UIColor.clear.cgColor
       textLayer.alignmentMode = CATextLayerAlignmentMode.left
       textLayer.contentsScale = UIScreen.main.scale
       textLayer.font = CTFontCreateWithName(UIFont.boldSystemFont(ofSize: 14.0).fontName as CFString, 0, nil)
       textLayer.fontSize = 14
       textLayer.string = title
       mainLayer.addSublayer(textLayer)
    }
    
    private func translateWidthValueToXPosition(value: Float) -> CGFloat
    {
       let width = CGFloat(value) * (mainLayer.frame.width - space)
       return abs(width)
    }
}