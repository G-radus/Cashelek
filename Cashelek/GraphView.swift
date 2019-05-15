//
//  GraphView.swift
//  Cashelek
//
//  Created by Rustam Gradov on 18/04/2019.
//  Copyright © 2019 Rustam Gradov. All rights reserved.
//

import Foundation
import UIKit


@IBDesignable //позволяет видеть в сториборде мой график
class GraphView: UIView {
    
    var values: [Double] = [120, 50, 300, 200, 100, 75] {
        didSet {
            setNeedsDisplay()
        }
    }
    @IBInspectable var lineColor: UIColor = UIColor.blue //Инспектбл - можно в сториборде менять свойства
    @IBInspectable var axisColor: UIColor = UIColor.black
    
    //namespace
    enum Settings {
        static let inset: CGFloat = 16
    }
    
    override func draw(_ rect: CGRect) {
        let bottom = rect.height - Settings.inset
        let left = Settings.inset
        let right = rect.width - Settings.inset
        let top = Settings.inset
        
        let axisXLength = rect.width - Settings.inset * 2
        let axisYLength = rect.height - Settings.inset * 2
        
        //рисуем ось X
        let axisX = UIBezierPath()
        axisX.lineWidth = 4
        axisX.move(to: CGPoint(x: left, y: bottom))
        axisX.addLine(to: CGPoint(x: right, y: bottom))
        //UIColor.red.setStroke() - поменять цвет которым рисуем линию
        axisX.stroke()
        
        //рисуем ось Y
        let axisY = UIBezierPath()
        axisY.lineWidth = 4
        axisY.move(to: CGPoint(x: left, y: bottom))
        axisY.addLine(to: CGPoint(x: left, y: top))
        axisY.stroke()
        
        guard values.count > 0 else { return }
        //окажемся на этой строке только если values.count > 0 будет true
        if values.count == 1 {
            
        } else {
            let maxValue = values.max()! * 1.1
            //шаг по оси X
            let step = axisXLength / CGFloat(values.count-1)
            
            let firstValue = values[0]
            //относительная часть оси Y, которую нужно заполнить
            //например, если верх оси = 100
            //то при значении 50 - нужно пройти половину оси
            let firstPart = firstValue / maxValue
            
            //берем низ оси Y и отнимаем высоту оси Y, умноженную на часть
            //которую нужно "заполнить"
            let firstY = bottom - axisYLength * CGFloat(firstPart)
            
            let path = UIBezierPath()
            //перемещаемся на первую точку
            path.move(to: CGPoint(x: left, y: firstY))
            //перебираем все точки после первой (не берем 0-вую)
            for i in 1..<values.count {
                //считаем часть
                let part = values[i] / maxValue
                //находим положение по вертикали
                let y = bottom - axisYLength * CGFloat(part)
                //по оси X = отступ от края + шаг * номер значения
                let x = left + step * CGFloat(i)
                //добавляем линию до этой точки
                path.addLine(to: CGPoint(x: x, y: y))
            }
            lineColor.setStroke()
            path.lineWidth = 4
            //непосредственно рисуем линию
            path.stroke()
        }
    }
}
