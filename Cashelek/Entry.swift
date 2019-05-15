//
//  Entry.swift
//  Cashelek
//
//  Created by Rustam Gradov on 11/04/2019.
//  Copyright © 2019 Rustam Gradov. All rights reserved.
//

import UIKit
import CoreData

//Создаем модель для показа в транзакциях после нажатия на кнопку Готово
@objc(Entry)
class Entry: NSManagedObject {
    
    @NSManaged var amount: Double
    @NSManaged var venue: Venue
    @NSManaged var category: String
    @NSManaged var date: Date

    convenience init(amount: Double, venue: Venue, category: String) {
        
        self.init(context: CoreDataHelper.shared.container.viewContext )
        
        self.amount = amount
        self.venue = venue
        self.category = category
        self.date = Date() //зафиксировать текущую дату
    }
    
    class func loadAllEntries() -> [Entry] {
        //создаю запрос к entity (классу, таблице) Entry
        let request = NSFetchRequest<Entry>(entityName: "Entry")
        //отсортировать результаты, а потом будет доставть из базы
        //ascending - по возрастанию
        request.sortDescriptors = [NSSortDescriptor(key: "date", ascending: false)]
        //выполяю
        let results = try! CoreDataHelper.shared.container.viewContext.fetch(request)
        
        return results
    }
    //если у меня есть таблица с данными, которые достаются из
    //CoreData, то нужно использовать NSFetchedResultsController 
    class func fetchedResultsController() -> NSFetchedResultsController<Entry> {
        let request = NSFetchRequest<Entry>(entityName: "Entry")
        request.sortDescriptors = [NSSortDescriptor(key: "date", ascending: false)]
        
        let controller = NSFetchedResultsController<Entry>(fetchRequest: request, managedObjectContext: CoreDataHelper.shared.container.viewContext, sectionNameKeyPath: nil, cacheName: "entries")
        
        return controller


    }
    
    //создаем метод, который будет выгружать данные только затрат
    class func loadLastAmounts() -> [Double] {
        //делаю запрос к базе
        let request = NSFetchRequest<NSDictionary>(entityName: "Entry")
        //чтобы достать последние значения
        request.sortDescriptors = [NSSortDescriptor(key: "date", ascending: false)]
        //берем последние 10 записей(первые 10 результатов)
        request.fetchLimit = 10
        //достаем только amount
        request.propertiesToFetch = ["amount"]
        //указываем, что результатом будет словарь
        request.resultType = .dictionaryResultType
        //выполняю запрос
        let results = try! CoreDataHelper.shared.container.viewContext.fetch(request)
        
        //long code
//        var amounts: [Double] = []
//        for result in results {
//            let amount = result["amount"] as! Double
//            amounts.append(amount)
//        }
        //для выбора значений, соответствующих словарю
        let amounts = results.map({ $0["amount"] as! Double}).reversed()
        
        //выражение выше - по-другому:
//        let amounts = results.map({ result in
//            return result["amount"] as! Double
//        })
        
        return Array(amounts)
    }
    //получаю данные для pieChart-а
    //беру значения категорий и суммы затрат на них
    class func sumCategories() -> [CategorySum ] {
        let sumExpression = NSExpression(forFunction: "sum:", arguments: [NSExpression(forKeyPath: "amount")])
        //подсчет суммы
        let expressionDescription = NSExpressionDescription()
        expressionDescription.expression = sumExpression
        expressionDescription.name = "sumAmount"
        expressionDescription.expressionResultType = .doubleAttributeType
        
        //достаю из базы значения
        //NSDictionary потому что мне нужен не весь Entry, а только 2 столбика
        let request = NSFetchRequest<NSDictionary>(entityName: "Entry")
        //говорю, что на выходе будут данные типа словаря
        request.resultType = .dictionaryResultType
        //группирую значения по названию категория
        request.propertiesToGroupBy = ["category"]
        //загружаю категории и суммы, подсчитанные выше
        request.propertiesToFetch = ["category", expressionDescription]
        
        let results = try! CoreDataHelper.shared.container.viewContext.fetch(request)
        
        var array: [CategorySum] = []
        for result in results {
            let value = CategorySum(name: result["category"] as! String,
                                    sum: result["sumAmount"] as! Double)
            array.append(value)
        }
        return array
    }
}

struct CategorySum {
    let name: String
    let sum: Double
}

