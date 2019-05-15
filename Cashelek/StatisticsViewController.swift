//
//  StatisticsViewController.swift
//  Cashelek
//
//  Created by Rustam Gradov on 18/04/2019.
//  Copyright © 2019 Rustam Gradov. All rights reserved.
//

import UIKit

class StatisticsViewController: UIViewController {

    
    @IBOutlet weak var graphView: GraphView!
    
    @IBOutlet weak var pieChart: PieChart!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        graphView.values = []

    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        updateValues()
        
    }
    
    func updateValues() {
        //достать значения и показать
        graphView.values = Entry.loadLastAmounts()
        
        let categories = Entry.sumCategories()
        //считаю общую сумму
        //reduce берет изначальное значение 0 и потом вызывает лямбду
        //с этим значением и каждым элементом списка
        //результат лямбды складывет вместо изначального значения
        let allSum = categories.reduce(0, {$0 + $1.sum})
        
        //беру элемент массива($0) categories, его сумму, делю на общую сумму и получаю
        //доли всех категорий
        //map вызывает лямду для каждого значения из массива
        //результатом будет массив результатов выполнения лямбд для каждого элемента
        let values = categories.map({ $0.sum / allSum })
        pieChart.values = values
    }
}
