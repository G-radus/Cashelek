//
//  Venue.swift
//  Cashelek
//
//  Created by Rustam Gradov on 10/04/2019.
//  Copyright © 2019 Rustam Gradov. All rights reserved.
//

import UIKit
import CoreData

//регистрирую класс в Obj-c для использования с CoreData
@objc(Venue)
//Создаю тип объекта, т.к. будет много свойств.
class Venue: NSManagedObject {
    ///уникальный идентификатор из 4square
    @NSManaged var id: String
    
    @NSManaged var name: String
    @NSManaged var address: String
    
    @NSManaged var latitude: Double
    @NSManaged var longitude: Double
    
    var distance: Int? // в метрах
    var iconURL: URL?
    
    class var entityDescription: NSEntityDescription {
        return NSEntityDescription.entity(forEntityName: "Venue", in: CoreDataHelper.shared.container.viewContext)!
    }
    
    convenience init() {
        //создаю объект, который нигде не хранится на момент создания
        self.init(entity: Venue.entityDescription, insertInto: nil)
    }
    //поискать в базе Venue  с таким же id
    class func getById(_ id: String) -> Venue? {
        let fetchRequest = NSFetchRequest<Venue>(entityName: "Venue")
        //запрос на поиск нужного объекта
        fetchRequest.predicate = NSPredicate(format: "id == %@", id)
        fetchRequest.fetchLimit = 1
        let results = try! CoreDataHelper.shared.container.viewContext.fetch(fetchRequest)
        let venue = results.first
        return venue
    }
    //делаю запрос к базе, чтобы вытащить все venue
    //чтобы пометить маркерами на карте мои места
    class func loadAllVenues() -> [Venue] {
        let fetchRequest = NSFetchRequest<Venue>(entityName: "Venue")
        let results = try! CoreDataHelper.shared.container.viewContext.fetch(fetchRequest)
        return results

    }
    
}
    //больше не нужен, т.к. нужно сохранять только выбранные пользователем объекты
    //а с инитом в контекст будут записываться все объекты, которые рядом
//    convenience init(name:String, address: String, distance: Int) {
//
//        self.init(context: CoreDataHelper.shared.container.viewContext)
//
//        self.name = name
//        self.address = address
//        self.distance = distance
//    }

//больше не нужен, убираю
//let sampleVenues = [
//    Venue(name: "Cafe Romashka", address: "Mne 7", distance: 100),
//    Venue(name: "AZS Kakashka", address: "Nah 45", distance: 200),
//    Venue(name: "Apteka Lopuh", address: "Poh 66", distance: 300),
//]
