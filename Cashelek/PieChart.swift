//
//  PieChart.swift
//  Cashelek
//
//  Created by Rustam Gradov on 19/04/2019.
//  Copyright © 2019 Rustam Gradov. All rights reserved.
//

import Foundation
import UIKit

//рисую круговую диаграмму
@IBDesignable
class PieChart: UIView {
    var values: [Double] = [0.2, 0.3, 0.1, 0.4] {
        didSet {
            setNeedsDisplay()
        }
    }
    var colors: [UIColor] = [.red, .brown, .blue, .green]
    
    override func draw(_ rect: CGRect) {
        let center = CGPoint(x: rect.width / 2, y: rect.height / 2)
        
        var currentAngle: CGFloat = 0
        
        for (i, value) in values.enumerated() {
            let color = colors[i]
            
            let angle = CGFloat.pi * 2 * CGFloat(value)
            
            let path = UIBezierPath()
            path.move(to: center)
            
            path.addArc(withCenter: center, radius: rect.width / 2,
                        startAngle: currentAngle,
                        endAngle: angle + currentAngle,
                        clockwise: true)
            
            path.close()
            
            color.setFill()
            path.fill()
            
            currentAngle += angle
        }
    }
}
